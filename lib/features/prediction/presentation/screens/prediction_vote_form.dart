import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class PredictionFormPage extends StatefulWidget {
  final String? nextRace;

  const PredictionFormPage({super.key, this.nextRace});

  @override
  State<PredictionFormPage> createState() => _PredictionFormPageState();
}

class _PredictionFormPageState extends State<PredictionFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _driver = "";
  String _team = "";

  final List<String> _driversList = [
    "Select a driver...",
    "Pierre Gasly",
    "Franco Colapinto",
    "Fernando Alonso",
    "Lance Stroll",
    "Charles Leclerc",
    "Lewis Hamilton",
    "Esteban Ocon",
    "Oliver Bearman",
    "Gabriel Bortoleto",
    "Nico Hulkenberg",
    "Lando Norris",
    "Oscar Piastri",
    "Kimi Antonelli",
    "George Russell",
    "Isack Hadjar",
    "Liam Lawson",
    "Max Verstappen",
    "Yuki Tsunoda",
    "Alex Albon",
    "Carlos Sainz",
  ];

  final List<String> _teamList = [
    "Select a team...",
    "Alpine",
    "Aston Martin",
    "Ferrari",
    "Haas",
    "Kick Sauber",
    "McLaren",
    "Mercedes",
    "Racing Bulls",
    "Red Bull",
    "Williams",
  ];

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();

    return Scaffold(
      appBar: AppBar(title: const Text("Vote")),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      "Make Your Vote",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Vote for your favorite driver and team",
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Driver select
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Driver",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                items: _driversList
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _driver = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value == "Select a driver...") {
                    return "Please select a driver";
                  }
                  return null;
                },
              ),
            ),

            // Team select
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Team",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                items: _teamList
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _team = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value == "Select a team...") {
                    return "Please select a team";
                  }
                  return null;
                },
              ),
            ),

            // Submit Button
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Post vote to Django
                      final response1 = await request.postJson(
                        "https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/prediction/post_vote_flutter",
                        jsonEncode({
                          "vote_type": "driver",
                          "race": widget.nextRace,
                          "content": _driver,
                        }),
                      );
                      final response2 = await request.postJson(
                        "https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/prediction/post_vote_flutter",
                        jsonEncode({
                          "vote_type": "team",
                          "race": widget.nextRace,
                          "content": _team,
                        }),
                      );

                      if (context.mounted) {
                        if (response1['status'] == 'success' &&
                            response2['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Vote posted!")),
                          );
                          context.pop(true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Something went wrong. Please try again later.",
                              ),
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text(
                    "Vote Now",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
