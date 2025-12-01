import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:pittalk_mobile/mainpage/presentation/widgets/sidebar.dart';
import 'package:pittalk_mobile/mainpage/presentation/widgets/mobile_sidebar_wrapper.dart';
import 'package:pittalk_mobile/features/information/data/drivers_standings_entry.dart' as driver_model;
import 'package:pittalk_mobile/features/information/data/teams_standings_entry.dart' as team_model;
import 'package:pittalk_mobile/features/information/data/drivers_entry.dart';
import 'package:pittalk_mobile/features/information/presentation/screens/drivers_detail.dart';
import 'package:pittalk_mobile/features/information/data/teams_entry.dart';
import 'package:pittalk_mobile/features/information/presentation/screens/teams_detail.dart';

class StandingsPage extends StatefulWidget {
  const StandingsPage({super.key});

  @override
  State<StandingsPage> createState() => _StandingsPageState();
}

class _StandingsPageState extends State<StandingsPage> {
  int _selectedTab = 0;
  bool _isLoading = true;
  
  List<driver_model.Datum> _driverStandings = [];
  List<team_model.Datum> _constructorStandings = [];

  final Map<String, Color> _teamColors = {
    "McLaren": const Color(0xFFf47500),
    "Ferrari": const Color(0xFFED1131),
    "Red Bull Racing": const Color(0xFF063279),
    "Mercedes": const Color(0xFF00ad91),
    "Aston Martin": const Color(0xFF085b3d),
    "Alpine": const Color(0xFF008fd1),
    "Haas": const Color(0xFF777b7e),
    "Racing Bulls": const Color(0xFF4e75dc),
    "Williams": const Color(0xFF0f42b8),
    "Kick Sauber": const Color(0xFF03ac0d),
  };

  @override
  void initState() {
    super.initState();
    fetchAllStandings();
  }

  Color _getTeamColor(String teamName) {
    return _teamColors[teamName] ?? Colors.grey;
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<void> fetchAllStandings() async {
    setState(() => _isLoading = true);

    const driversUrl = 'http://localhost:8000/information/api/standings/drivers/2025/';
    const constructorsUrl = 'http://localhost:8000/information/api/standings/constructors/2025/';

    try {
      final responses = await Future.wait([
        http.get(Uri.parse(driversUrl)),
        http.get(Uri.parse(constructorsUrl)),
      ]);

      final driverRes = responses[0];
      final teamRes = responses[1];

      if (driverRes.statusCode == 200 && teamRes.statusCode == 200) {
        final driverJson = json.decode(driverRes.body);
        final driverEntry = driver_model.DriversStandingsEntry.fromJson(driverJson);
        
        final teamJson = json.decode(teamRes.body);
        final teamEntry = team_model.TeamsStandingsEntry.fromJson(teamJson);

        setState(() {
          _driverStandings = driverEntry.data;
          _constructorStandings = teamEntry.data;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load standings');
      }
    } catch (e) {
      debugPrint("Error fetching standings: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToDriverDetail(String driverUrl) async {
    final uri = Uri.parse(driverUrl);
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return;
    final slug = segments.last;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final url = 'http://localhost:8000/information/api/drivers/$slug/';
      final response = await http.get(Uri.parse(url));

      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        Map<String, dynamic> dataToParse = jsonData.containsKey('data') ? jsonData['data'] : jsonData;
        
        if (dataToParse.containsKey('number')) dataToParse['number'] = _parseInt(dataToParse['number']);
        if (dataToParse.containsKey('podiums')) dataToParse['podiums'] = _parseInt(dataToParse['podiums']);
        if (dataToParse.containsKey('points')) dataToParse['points'] = _parseDouble(dataToParse['points']);
        if (dataToParse.containsKey('grands_prix_entered')) dataToParse['grands_prix_entered'] = _parseInt(dataToParse['grands_prix_entered']);
        if (dataToParse.containsKey('world_championships')) dataToParse['world_championships'] = _parseInt(dataToParse['world_championships']);

        final driverEntry = DriversEntry.fromJson(dataToParse);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverDetailPage(driver: driverEntry),
          ),
        );
      } else {
        throw Exception("Failed to load driver data");
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _navigateToTeamDetail(String teamUrl) async {
    final uri = Uri.parse(teamUrl);
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return;
    final slug = segments.last;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final url = 'http://localhost:8000/information/api/teams/$slug/';
      final response = await http.get(Uri.parse(url));

      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        Map<String, dynamic> dataToParse = jsonData.containsKey('data') ? jsonData['data'] : jsonData;
        
        if (dataToParse.containsKey('first_team_entry')) dataToParse['first_team_entry'] = _parseInt(dataToParse['first_team_entry']);
        if (dataToParse.containsKey('world_championships')) dataToParse['world_championships'] = _parseInt(dataToParse['world_championships']);
        if (dataToParse.containsKey('pole_positions')) dataToParse['pole_positions'] = _parseInt(dataToParse['pole_positions']);
        if (dataToParse.containsKey('fastest_laps')) dataToParse['fastest_laps'] = _parseInt(dataToParse['fastest_laps']);

        final teamEntry = TeamsEntry.fromJson(dataToParse);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeamDetailPage(team: teamEntry),
          ),
        );
      } else {
        throw Exception("Failed to load team data");
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildDriverCard(driver_model.Datum driver, int index) {
    final position = index + 1;
    final teamColor = _getTeamColor(driver.team);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDriverDetail(driver.url),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: teamColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),

                SizedBox(
                  width: 30,
                  child: Text(
                    "$position",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.driver,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        driver.team,
                        style: GoogleFonts.inter(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${driver.points}",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      "PTS",
                      style: GoogleFonts.inter(
                        color: Colors.grey[500],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(width: 12),
                Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.3), size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConstructorCard(team_model.Datum team, int index) {
    final position = index + 1;
    final teamColor = _getTeamColor(team.team);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToTeamDetail(team.url),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: teamColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),

                SizedBox(
                  width: 30,
                  child: Text(
                    "$position",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Text(
                    team.team,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${team.points}",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      "PTS",
                      style: GoogleFonts.inter(
                        color: Colors.grey[500],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),
                Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.3), size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: fetchAllStandings,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "2025 Standings",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Track the latest points, position changes, and championship battles.",
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white12)),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _selectedTab == 0 ? Colors.red : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          "Drivers",
                          style: GoogleFonts.inter(
                            color: _selectedTab == 0 ? Colors.white : Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _selectedTab == 1 ? Colors.red : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          "Constructors",
                          style: GoogleFonts.inter(
                            color: _selectedTab == 1 ? Colors.white : Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _selectedTab == 0
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _driverStandings.length,
                      itemBuilder: (context, index) {
                        return _buildDriverCard(_driverStandings[index], index);
                      },
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _constructorStandings.length,
                      itemBuilder: (context, index) {
                        return _buildConstructorCard(_constructorStandings[index], index);
                      },
                    ),
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
                "Standings",
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
              child: _buildContent(context),
            ),
          ),
        ],
      ),
    );

    if (!isDesktop) {
      return MobileSidebarWrapper(
        currentRoute: currentRoute,
        child: content,
      );
    }

    return content;
  }
}