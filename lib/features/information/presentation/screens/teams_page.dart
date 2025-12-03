import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:pittalk_mobile/features/information/data/teams_entry.dart';
import 'package:pittalk_mobile/features/information/presentation/widgets/team_card.dart';
import 'package:pittalk_mobile/mainpage/presentation/widgets/sidebar.dart';
import 'package:pittalk_mobile/mainpage/presentation/widgets/mobile_sidebar_wrapper.dart';
import 'package:pittalk_mobile/features/information/presentation/screens/teams_detail.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  List<TeamsEntry> _allTeams = [];
  List<TeamsEntry> _filteredTeams = [];
  String _searchQuery = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    const url = 'http://localhost:8000/information/api/teams/'; 
    
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _allTeams = data.map((x) => TeamsEntry.fromJson(x)).toList();
          _filteredTeams = _allTeams;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load teams');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint("Error fetching teams: $e");
    }
  }

  void _runFilter(String enteredKeyword) {
    List<TeamsEntry> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allTeams;
    } else {
      results = _allTeams.where((team) {
        final name = team.name.toLowerCase();
        final fullName = team.fullName.toLowerCase();
        final keyword = enteredKeyword.toLowerCase();
        return name.contains(keyword) || fullName.contains(keyword);
      }).toList();
    }

    setState(() {
      _filteredTeams = results;
      _searchQuery = enteredKeyword;
    });
  }

  Widget _buildContent(BuildContext context, bool isDesktop) {
    int gridCount = isDesktop ? 2 : 1;
    double aspectRatio = isDesktop ? 2.5 : 2.1;

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: fetchTeams,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "2025 Teams",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Discover the constructors, leadership, and engineering behind each car.",
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: TextField(
                      onChanged: (value) => _runFilter(value),
                      style: GoogleFonts.inter(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF262626),
                        hintText: "Search by team name...",
                        hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (_filteredTeams.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Text(
                          "No teams found",
                          style: GoogleFonts.inter(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: aspectRatio,
                        ),
                        itemCount: _filteredTeams.length,
                        itemBuilder: (context, index) {
                          final team = _filteredTeams[index];
                          
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeamDetailPage(team: team),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: TeamCard(team: team),
                          );
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
                "Teams",
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFF171717),
              foregroundColor: Colors.white,
            ),

      body: Row(
        children: [
          if (isDesktop)
            PitTalkSidebar(
              currentRoute: currentRoute,
            ),

          Expanded(
            child: Container(
              color: const Color(0xFF171717),
              child: _buildContent(context, isDesktop),
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