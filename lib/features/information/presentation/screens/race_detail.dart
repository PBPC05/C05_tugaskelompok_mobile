import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:pittalk_mobile/features/information/data/races_entry.dart';
import 'package:pittalk_mobile/features/information/data/drivers_entry.dart';
import 'package:pittalk_mobile/features/information/presentation/screens/drivers_detail.dart';

class RaceDetailPage extends StatefulWidget {
  final String raceUrl; 
  final String raceName;

  const RaceDetailPage({
    super.key, 
    required this.raceUrl,
    this.raceName = "Race Detail",
  });

  @override
  State<RaceDetailPage> createState() => _RaceDetailPageState();
}

class _RaceDetailPageState extends State<RaceDetailPage> {
  RacesEntry? _raceData;
  bool _isLoading = true;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchRaceDetail();
  }

  Color _parseColor(String hexColor) {
    try {
      hexColor = hexColor.replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF$hexColor";
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.white;
    }
  }

  Future<void> fetchRaceDetail() async {
    final uri = Uri.parse(widget.raceUrl);
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    final slug = segments.isNotEmpty ? segments.last : "";
    final url = 'https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/information/api/races/$slug/';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final dataToParse = jsonData.containsKey('data') ? jsonData['data'] : jsonData;

        setState(() {
          _raceData = RacesEntry.fromJson(dataToParse);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load race details');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      debugPrint("Error fetching race detail: $e");
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
      final url = 'https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/information/api/drivers/$slug/';
      final response = await http.get(Uri.parse(url));

      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final dataToParse = jsonData.containsKey('data') ? jsonData['data'] : jsonData;
        
        final driverEntry = DriversEntry.fromJson(dataToParse);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverDetailPage(driver: driverEntry),
          ),
        );
      } else {
        throw Exception("Failed to load driver profile");
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not load driver: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildPodiumCard(Result result, {bool isWinner = false}) {
    final teamColor = _parseColor(result.team.color);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isWinner ? teamColor : Colors.white.withOpacity(0.1), 
          width: isWinner ? 2 : 1
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _navigateToDriverDetail(result.driver.url),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "P${result.position}",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: isWinner ? 36 : 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (result.fastestLap)
                      const Icon(Icons.timer, color: Colors.purpleAccent, size: 24),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  result.driver.fullName,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: isWinner ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  result.team.name,
                  style: GoogleFonts.inter(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 20),
                Divider(color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 12),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Time", style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
                        Text(
                          result.timeText,
                          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("Points", style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
                        Text(
                          "${result.points} PTS",
                          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(Result result) {
    final teamColor = _parseColor(result.team.color);
    
    final isFinished = result.status == Status.FINISHED;
    
    final positionText = result.position?.toString() ?? result.status.name;
    
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: InkWell( 
        onTap: () => _navigateToDriverDetail(result.driver.url),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: teamColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      positionText,
                      style: GoogleFonts.inter(
                        color: isFinished ? Colors.white : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.driver.fullName,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      result.team.name,
                      style: GoogleFonts.inter(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Text(
                  result.timeText,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    color: Colors.grey[300],
                    fontSize: 13,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),

              SizedBox(
                width: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${result.points} PTS",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13
                      ),
                    ),
                    if (result.fastestLap)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(Icons.timer, color: Colors.purpleAccent, size: 14),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isLoading ? "Loading..." : (_raceData?.name ?? "Race Details"),
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 120, 24, 40),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.red.withOpacity(0.2), 
                              const Color(0xFF171717),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${_raceData!.circuit} // Round ${_raceData!.round}",
                              style: GoogleFonts.inter(
                                color: Colors.grey[400],
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _raceData!.name,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _raceData!.date,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (!_raceData!.hasResults)
                         Container(
                           margin: const EdgeInsets.all(24),
                           padding: const EdgeInsets.all(40),
                           decoration: BoxDecoration(
                             color: const Color(0xFF262626),
                             borderRadius: BorderRadius.circular(24),
                             border: Border.all(color: Colors.white10),
                           ),
                           child: Column(
                             children: [
                               const Text("🏁", style: TextStyle(fontSize: 60)),
                               const SizedBox(height: 16),
                               Text(
                                 "Race Not Yet Run",
                                 style: GoogleFonts.inter(
                                   color: Colors.white,
                                   fontSize: 24,
                                   fontWeight: FontWeight.bold
                                 ),
                               ),
                               const SizedBox(height: 8),
                               Text(
                                 "The results for this Grand Prix are not yet available.",
                                 textAlign: TextAlign.center,
                                 style: GoogleFonts.inter(color: Colors.grey[400]),
                               ),
                             ],
                           ),
                         )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Podium",
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              ..._raceData!.results.take(3).map((res) {
                                return _buildPodiumCard(res, isWinner: res.position == 1);
                              }),

                              const SizedBox(height: 32),

                              Text(
                                "Full Results",
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF262626),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _raceData!.results.length > 3 ? _raceData!.results.length - 3 : 0,
                                  itemBuilder: (context, index) {
                                    final result = _raceData!.results[index + 3];
                                    return _buildResultRow(result);
                                  },
                                ),
                              ),
                              
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}