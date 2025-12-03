import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pittalk_mobile/features/information/data/schedule_entry.dart';
import 'package:pittalk_mobile/mainpage/presentation/widgets/sidebar.dart';
import 'package:pittalk_mobile/mainpage/presentation/widgets/mobile_sidebar_wrapper.dart';
import 'package:pittalk_mobile/features/information/presentation/screens/race_detail.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<Race> _races = [];
  Race? _nextRace;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSchedule();
  }

  Future<void> fetchSchedule() async {
    const url = 'http://localhost:8000/information/api/schedule/2025';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        final scheduleData = ScheduleEntry.fromJson(jsonResponse);
        
        final List<Race> races = scheduleData.data;
        
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        Race? upcoming;
        for (var race in races) {
          if (race.date.compareTo(today) >= 0) {
            upcoming = race;
            break;
          }
        }

        setState(() {
          _races = races;
          _nextRace = upcoming;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load schedule');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint("Error fetching schedule: $e");
    }
  }

  Widget _buildNextRaceCard() {
    if (_nextRace == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              "Season Concluded",
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              "See you next season!",
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final race = _nextRace!;
    final startDate = race.date.subtract(const Duration(days: 2));
    final startDay = DateFormat('dd').format(startDate);
    final endDay = DateFormat('dd').format(race.date);
    final month = DateFormat('MMM').format(race.date).toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RaceDetailPage(
                  raceUrl: race.url,
                  raceName: race.name,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "NEXT RACE",
                            style: GoogleFonts.inter(
                              color: const Color(0xFFF87171),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$startDay-$endDay $month",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Round ${race.roundNumber}",
                            style: GoogleFonts.inter(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            race.name,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            race.circuit,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.inter(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "View Details →",
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRaceListItem(Race race, bool isNext) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isCompleted = race.date.isBefore(today);

    final opacity = isCompleted ? 0.5 : 1.0;
    final borderColor = isNext ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.1);
    final bgColor = isNext ? const Color(0xFF2A2A2A) : const Color(0xFF262626);

    final day = DateFormat('dd').format(race.date);
    final month = DateFormat('MMM').format(race.date).toUpperCase();

    return Opacity(
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RaceDetailPage(
                  raceUrl: race.url,
                  raceName: race.name,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 60,
                  padding: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
                  ),
                  child: Column(
                    children: [
                      Text(
                        month,
                        style: GoogleFonts.inter(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        day,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Round ${race.roundNumber}",
                        style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        race.name,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        race.circuit,
                        style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "COMPLETED",
                      style: GoogleFonts.inter(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  )
                else if (isNext)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "NEXT RACE",
                      style: GoogleFonts.inter(color: Colors.red[300], fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),

                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: fetchSchedule,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "2025 Race Calendar",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "All Grand Prix dates, circuits, and start times, stay ahead of the season.",
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildNextRaceCard(),

                  Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.white12)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Full Calendar",
                          style: GoogleFonts.inter(
                            color: Colors.grey[500],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Colors.white12)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _races.length,
                    itemBuilder: (context, index) {
                      final race = _races[index];
                      final isNext = _nextRace != null && race.date == _nextRace!.date;
                      return _buildRaceListItem(race, isNext);
                    },
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final content = Scaffold(
      backgroundColor: const Color(0xFF171717),
      appBar: isDesktop
          ? null
          : AppBar(
              title: Text(
                "Schedule",
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFF171717),
              foregroundColor: Colors.white,
            ),
      body: Row(
        children: [
          if (isDesktop)
            PitTalkSidebar(currentRoute: currentRoute),
          Expanded(
            child: Container(
              color: const Color(0xFF171717),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );

    if (!isDesktop) {
      return MobileSidebarWrapper(currentRoute: currentRoute, child: content);
    }

    return content;
  }
}