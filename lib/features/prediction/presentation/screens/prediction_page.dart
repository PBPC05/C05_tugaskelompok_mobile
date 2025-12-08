import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:pittalk_mobile/features/prediction/data/prediction_model.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  String nextRaceDisplay = "Loading...";
  Map<String, int> driverVotes = {};
  Map<String, int> teamVotes = {};

  final List<Color> chartColors = [
    Colors.red,
    Colors.blue,
    Colors.yellow,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    loadNextRace();
    getVotes();
  }

  // Get next race data
  Future<Map<String, dynamic>?> getNextRace(CookieRequest request) async {
    final scheduleData = await request.get(
      "https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/information/api/schedule/2025/",
    );

    if (scheduleData == null || scheduleData['data'] == null) {
      throw Exception("Invalid data structure");
    }

    final races = scheduleData['data'] as List;

    final today = DateTime.now();
    final cleanToday = DateTime(today.year, today.month, today.day);

    Map<String, dynamic>? nextRace;
    bool nextRaceFound = false;

    for (var race in races) {
      final raceDate = DateTime.parse("${race['date']}T00:00:00Z");
      if (raceDate.isAfter(cleanToday) ||
          raceDate.isAtSameMomentAs(cleanToday)) {
        nextRace = race;
        nextRaceFound = true;
        break;
      }
    }

    if (!nextRaceFound) {
      nextRace = races.last;
    }

    return nextRace;
  }

  void loadNextRace() async {
    final request = context.read<CookieRequest>();
    final race = await getNextRace(request);

    if (race != null) {
      setState(() {
        nextRaceDisplay = "${race['season']} ${race['name']}";
      });
    }
  }

  void getVotes() async {
    driverVotes.clear();
    teamVotes.clear();

    final request = context.read<CookieRequest>();
    final response = await request.get(
      "https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/prediction/json",
    );

    var allVotes = response;
    Map<String, int> driverTemp = {};
    Map<String, int> teamTemp = {};
    for (var v in allVotes) {
      if (v != null) {
        var vote = Vote.fromJson(v);
        if (vote.voteType == 'driver') {
          driverTemp[vote.content] = (driverTemp[vote.content] ?? 0) + 1;
        } else if (vote.voteType == 'team') {
          teamTemp[vote.content] = (teamTemp[vote.content] ?? 0) + 1;
        }
      }
    }

    setState(() {
      driverVotes = driverTemp;
      teamVotes = teamTemp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(title: const Text("Prediction")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current race
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade900),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Current Race:",
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                  Text(
                    nextRaceDisplay,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Clear votes button for admins
                  ElevatedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Confirm Clear"),
                            content: const Text(
                              "Are you sure you want to clear all votes for this race? This action cannot be undone!",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  "Clear",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm != true) return;

                      final response = await request.post(
                        "https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/prediction/clear_votes_flutter",
                        "",
                      );

                      if (context.mounted) {
                        if (response['status'] == 'ok') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Votes cleared!")),
                          );
                          context.pop(true);
                        }
                      }
                    },
                    child: const Text("Clear Votes"),
                  ),
                ],
              ),
            ),

            // Drivers vote
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12.0),
              child: const Text(
                "Drivers",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32.0,
                  color: Colors.white,
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 2.0,
                horizontal: 12.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Container(
                margin: const EdgeInsets.all(8.0),
                width: double.infinity,
                height: 250,
                child: driverVotes.isEmpty
                    ? const Text(
                        "No votes yet. Be the first to vote on this race!",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : PieChart(
                        PieChartData(
                          centerSpaceRadius: 0,
                          sections: driverVotes.entries
                              .toList()
                              .asMap()
                              .entries
                              .map((m) {
                                final i = m.key;
                                final k = m.value;
                                return PieChartSectionData(
                                  title: k.key,
                                  titleStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  value: k.value.toDouble(),
                                  radius: 120,
                                  color: chartColors[i % chartColors.length],
                                );
                              })
                              .toList(),
                        ),
                      ),
              ),
            ),

            // Teams vote
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12.0),
              child: const Text(
                "Teams",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32.0,
                  color: Colors.white,
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 2.0,
                horizontal: 12.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Container(
                margin: const EdgeInsets.all(8.0),
                width: double.infinity,
                height: 250,
                child: teamVotes.isEmpty
                    ? const Text(
                        "No votes yet. Be the first to vote on this race!",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : PieChart(
                        PieChartData(
                          centerSpaceRadius: 0,
                          sections: teamVotes.entries
                              .toList()
                              .asMap()
                              .entries
                              .map((m) {
                                final i = m.key;
                                final k = m.value;
                                return PieChartSectionData(
                                  title: k.key,
                                  titleStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  value: k.value.toDouble(),
                                  radius: 120,
                                  color: chartColors[i % chartColors.length],
                                );
                              })
                              .toList(),
                        ),
                      ),
              ),
            ),

            // Vote button
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 32.0,
                horizontal: 16.0,
              ),
              height: 100,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final updated = await context.push(
                    '/prediction/vote/',
                    extra: nextRaceDisplay,
                  );

                  if (updated == true) getVotes();
                },
                child: const Text("Vote Now", style: TextStyle(fontSize: 24.0)),
              ),
            ),

            const Divider(height: 64),
          ],
        ),
      ),
    );
  }
}
