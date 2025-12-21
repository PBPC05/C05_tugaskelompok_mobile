import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pittalk_mobile/features/information/data/teams_entry.dart';

class TeamDetailPage extends StatelessWidget {
  final TeamsEntry team;

  const TeamDetailPage({super.key, required this.team});

  // Helper: Parse Hex Color
  Color _parseColor(String hexColor) {
    try {
      hexColor = hexColor.toUpperCase().replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF$hexColor";
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return const Color(0xFF333333);
    }
  }

  // Helper: High Res Image
  String _getHigherResImageUrl(String url) {
    if (url.isEmpty) return '';
    // Mengganti parameter resize F1 agar gambar lebih tajam di HP
    return url.replaceAll(RegExp(r',(h_\d+|w_\d+)'), ',h_600');
  }

  // Widget: Baris Informasi (Info List)
  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget: Kartu Statistik (Stats Grid)
  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF262626), // Neutral 800
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.grey[400],
              fontSize: 13,
              height: 1.2,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 24, // Angka besar
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teamColor = _parseColor(team.color);
    final logoUrl = _getHigherResImageUrl(team.teamLogo);

    return Scaffold(
      backgroundColor: const Color(0xFF171717), // Neutral 900
      extendBodyBehindAppBar: true, // AppBar transparan di atas hero
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
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // --- 1. HERO SECTION ---
            Container(
              height: 480, // Tinggi hero section
              width: double.infinity,
              decoration: BoxDecoration(
                color: teamColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: teamColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Stack(
                children: [
                  // Layer 1: Logo Watermark (Besar & Transparan di Background)
                  Positioned(
                    right: -50,
                    bottom: -50,
                    child: Opacity(
                      opacity: 0.15, // Efek watermark
                      child: Image.network(
                        logoUrl,
                        height: 400,
                        fit: BoxFit.contain,
                        errorBuilder: (_,__,___) => const SizedBox(),
                      ),
                    ),
                  ),

                  // Layer 2: Gradient Overlay (Agar teks terbaca)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3), // Atas gelap dikit buat AppBar
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Layer 3: Konten Teks Hero
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 60, // Jarak dari bawah curve
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo Kecil (Opsional, kalau mau ada logo solid di atas teks)
                        // Image.network(logoUrl, height: 60), 
                        // const SizedBox(height: 16),

                        Text(
                          team.fullName, // Nama Lengkap Tim
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            shadows: [
                              Shadow(
                                offset: const Offset(2, 2),
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white70, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              team.base, // Lokasi Markas
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. KONTEN DETAIL ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // --- TEAM STATS (Grid) ---
                  Text(
                    "Team Stats",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  GridView.count(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4, // Rasio kartu
                    children: [
                      _buildStatCard("World Championships", team.worldChampionships.toString()),
                      _buildStatCard("Pole Positions", team.polePositions.toString()),
                      _buildStatCard("Fastest Laps", team.fastestLaps.toString()),
                      _buildStatCard("Highest Race Finish", team.highestRaceFinish),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // --- INFORMATION LIST ---
                  Text(
                    "Information",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626), // Neutral 800
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow("Team Chief", team.teamChief),
                        _buildInfoRow("Technical Chief", team.technicalChief),
                        _buildInfoRow("Chassis", team.chassis),
                        _buildInfoRow("Power Unit", team.powerUnit),
                        _buildInfoRow("First Entry", team.firstTeamEntry.toString()),
                      ],
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