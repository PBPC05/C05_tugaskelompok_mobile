import 'package:flutter/material.dart';
import 'package:pittalk_mobile/features/information/data/drivers_entry.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverCard extends StatelessWidget {
  final DriversEntry driver;

  const DriverCard({super.key, required this.driver});

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

  @override
  Widget build(BuildContext context) {
    final teamColor = _parseColor(driver.color);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(color: teamColor.withOpacity(0.25)),
            ),

            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 180, 
              child: Image.network(
                driver.driverImage,
                fit: BoxFit.cover, 
                alignment: Alignment.topCenter, 
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, size: 80, color: Colors.grey),
              ),
            ),

            Positioned(
              left: 24,
              top: 24,
              bottom: 24,
              right: 160, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver.fullName,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  Text(
                    driver.team,
                    style: GoogleFonts.inter(
                      color: Colors.grey[300],
                      fontSize: 14,
                    ),
                  ),
                  
                  const Spacer(), 
                  
                  if (driver.numberImage.isNotEmpty)
                    Image.network(
                      driver.numberImage,
                      height: 60,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                      errorBuilder: (context, error, stackTrace) => Text(
                        "#${driver.number}",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}