import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:pittalk_mobile/features/information/data/drivers_entry.dart';
import 'package:pittalk_mobile/features/information/presentation/widgets/drivers_entry_card.dart';
import 'package:pittalk_mobile/features/information/presentation/screens/drivers_detail.dart';
import 'package:pittalk_mobile/mainpage/presentation/widgets/sidebar.dart';
import 'package:pittalk_mobile/mainpage/presentation/widgets/mobile_sidebar_wrapper.dart';

class DriversEntryPage extends StatefulWidget {
  const DriversEntryPage({super.key});

  @override
  State<DriversEntryPage> createState() => _DriversEntryPageState();
}

class _DriversEntryPageState extends State<DriversEntryPage> {
  List<DriversEntry> _allDrivers = [];
  List<DriversEntry> _filteredDrivers = [];
  String _searchQuery = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDrivers();
  }

  Future<void> fetchDrivers() async {
    const url = 'https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/information/api/drivers/';
    
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _allDrivers = data.map((x) => DriversEntry.fromJson(x)).toList();
          _filteredDrivers = _allDrivers;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load drivers');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint("Error fetching data: $e");
    }
  }

  void _runFilter(String enteredKeyword) {
    List<DriversEntry> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allDrivers;
    } else {
      results = _allDrivers
          .where((driver) =>
              driver.fullName.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredDrivers = results;
      _searchQuery = enteredKeyword;
    });
  }

  Widget _buildContent(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: fetchDrivers,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "2025 Drivers",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Explore every driver’s profile, stats, and story from the 2025 F1 season.",
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
                        hintText: "Search by driver name...",
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

                  const SizedBox(height: 10),

                  if (_filteredDrivers.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Text(
                          "No drivers found",
                          style: GoogleFonts.inter(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredDrivers.length,
                      itemBuilder: (context, index) {
                        final driver = _filteredDrivers[index];
                        
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DriverDetailPage(driver: driver),
                              ),
                            );
                          },
                          splashColor: Colors.white.withOpacity(0.1),
                          highlightColor: Colors.white.withOpacity(0.05),
                          child: DriverCard(driver: driver),
                        );
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
                "Drivers", 
                style: GoogleFonts.inter(fontWeight: FontWeight.bold)
              ),
              backgroundColor: const Color(0xFF171717),
              foregroundColor: Colors.white,
            ),

      body: Row(
        children: [

          Expanded(
            child: Container(
              color: const Color(0xFF171717),
              child: _buildContent(context),
            ),
          ),
        ],
      ),
    );

    return content;
  }
}