import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pittalk_mobile/features/information/data/drivers_entry.dart';

class DriverDetailPage extends StatelessWidget {
  final DriversEntry driver;

  const DriverDetailPage({super.key, required this.driver});

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

  String _getHigherResImageUrl(String url, int height) {
    if (url.isEmpty) return '';
    return url.replaceAll(RegExp(r',(h_\d+|w_\d+)'), ',h_$height');
  }

  Widget _buildBioRow(String label, String value) {
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

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
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
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teamColor = _parseColor(driver.color);
    
    final highResDriverImg = _getHigherResImageUrl(driver.driverImage, 1000);

    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle
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
            Container(
              height: 500, 
              width: double.infinity,
              decoration: BoxDecoration(
                color: teamColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.05,
                      child: Container(
                         decoration: const BoxDecoration(
                           gradient: LinearGradient(
                             begin: Alignment.topCenter,
                             end: Alignment.bottomCenter,
                             colors: [Colors.black, Colors.transparent]
                           )
                         ),
                      ),
                    ),
                  ),

                  Positioned(
                    left: 24,
                    top: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 200,
                          child: Text(
                            driver.fullName,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                              shadows: [
                                Shadow(offset: const Offset(2, 2), blurRadius: 10, color: Colors.black.withOpacity(0.3))
                              ]
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          driver.team,
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                        const SizedBox(height: 40),

                        if (driver.numberImage.isNotEmpty)
                          Opacity(
                            opacity: 0.9,
                            child: Image.network(
                              driver.numberImage,
                              height: 100,
                              fit: BoxFit.contain,
                              errorBuilder: (_,__,___) => Text(
                                "#${driver.number}",
                                style: GoogleFonts.inter(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white54)
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Positioned(
                    right: -40,
                    bottom: 0,
                    top: 80,
                    width: 400,
                    child: Image.network(
                      highResDriverImg,
                      fit: BoxFit.cover,
                      alignment: Alignment.topLeft,
                      errorBuilder: (_,__,___) => const SizedBox(),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Career Stats",
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
                    childAspectRatio: 1.4, 
                    children: [
                      _buildStatCard("World Championships", driver.worldChampionships.toString()),
                      _buildStatCard("Podiums", driver.podiums.toString()),
                      _buildStatCard("Career Points", driver.points.toString()),
                      _buildStatCard("Grands Prix Entered", driver.grandsPrixEntered.toString()),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Text(
                    "Biography",
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
                      color: const Color(0xFF262626),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        _buildBioRow("Country", driver.country),
                        _buildBioRow("Date of Birth", driver.dateOfBirth),
                        _buildBioRow("Place of Birth", driver.placeOfBirth),
                        _buildBioRow("Highest Race Finish", driver.highestRaceFinish),
                        _buildBioRow("Highest Grid Position", driver.highestGridPosition),
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