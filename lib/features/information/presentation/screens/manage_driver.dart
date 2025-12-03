// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:pbp_django_auth/pbp_django_auth.dart';
// import 'package:provider/provider.dart';
// import 'package:google_fonts/google_fonts.dart';

// // --- IMPORTS UNTUK NAVIGASI QUICK ACTIONS ---
// import 'package:pittalk_mobile/features/authentication/presentation/screens/manage_users_screen.dart';
// // import 'package:pittalk_mobile/features/information/presentation/screens/manage_teams_screen.dart';

// class ManageDriversScreen extends StatefulWidget {
//   const ManageDriversScreen({super.key});

//   @override
//   State<ManageDriversScreen> createState() => _ManageDriversScreenState();
// }

// class _ManageDriversScreenState extends State<ManageDriversScreen> {
//   bool _isLoading = true;
//   bool _isAdmin = true;
//   List<Map<String, dynamic>> _drivers = [];

//   // Controller
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _podiumsController = TextEditingController();
//   final TextEditingController _pointsController = TextEditingController();
//   final TextEditingController _entriesController = TextEditingController();
//   final TextEditingController _champsController = TextEditingController();
//   final TextEditingController _highestRaceController = TextEditingController();
//   final TextEditingController _highestGridController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _fetchDrivers();
//   }

//   @override
//   void dispose() {
//     _podiumsController.dispose();
//     _pointsController.dispose();
//     _entriesController.dispose();
//     _champsController.dispose();
//     _highestRaceController.dispose();
//     _highestGridController.dispose();
//     super.dispose();
//   }

//   // --- 1. FETCH DATA ---
//   Future<void> _fetchDrivers() async {
//     final request = context.read<CookieRequest>();
//     try {
//       final response = await request.get('https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/information/api/drivers/');
      
//       if (response != null) {
//         setState(() {
//           _drivers = List<Map<String, dynamic>>.from(response);
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching drivers: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load drivers: $e')),
//         );
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   // --- 2. UPDATE LOGIC (DIPERBAIKI LAGI) ---
//   Future<void> _updateDriver(int driverId) async {
//     if (!_formKey.currentState!.validate()) return;

//     final request = context.read<CookieRequest>();
//     // URL Update
//     final url = 'https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/information/driver/$driverId/update/ajax/';

//     try {
//       // Mengirim data form update
//       // Kita gunakan request.post (bukan postJson) karena backend mungkin expect form-data
//       final response = await request.post(url, jsonEncode({
//         'podiums': _podiumsController.text,
//         'points': _pointsController.text,
//         'grands_prix_entered': _entriesController.text,
//         'world_championships': _champsController.text,
//         'highest_race_finish': _highestRaceController.text,
//         'highest_grid_position': _highestGridController.text,
//       }));

//       // DEBUGGING RESPONSE
//       debugPrint("Status Code: ${request.jsonData['status'] ?? 'OK'}");
//       debugPrint("Response Body: $response");

//       // Cek apakah response berupa Map JSON yang valid
//       if (response['ok'] == true) {
//         if (mounted) {
//           Navigator.pop(context);
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Driver updated successfully!'), backgroundColor: Colors.green),
//           );
//           _fetchDrivers();
//         }
//       } else {
//         // Handle error dari server
//         String errorMessage = 'Update failed';
//         if (response['errors'] != null) {
//             errorMessage = response['errors'].toString();
//         } else if (response['message'] != null) {
//             errorMessage = response['message'];
//         }
        
//         if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
//             );
//         }
//       }
//     } catch (e) {
//       debugPrint("AJAX UPDATE ERROR: $e"); 
      
//       String msg = "Error: $e";
//       // Deteksi jika error karena HTML (Session expired / 403 Forbidden)
//       if (e.toString().toLowerCase().contains("syntaxerror") || e.toString().contains("<")) {
//           msg = "Session Error: Server returned HTML. Please Logout & Login again.";
//       }
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(msg), backgroundColor: Colors.red, duration: const Duration(seconds: 4)),
//         );
//       }
//     }
//   }

//   // --- 3. EDIT DIALOG ---
//   void _showEditDialog(Map<String, dynamic> driver) {
//     _podiumsController.text = driver['podiums']?.toString() ?? '0';
//     _pointsController.text = driver['points']?.toString() ?? '0.0';
//     _entriesController.text = driver['grands_prix_entered']?.toString() ?? '0';
//     _champsController.text = driver['world_championships']?.toString() ?? '0';
//     _highestRaceController.text = driver['highest_race_finish']?.toString() ?? '';
//     _highestGridController.text = driver['highest_grid_position']?.toString() ?? '';

//     dynamic rawId = driver['pk'] ?? driver['id'];
//     int? driverId;

//     if (rawId != null) {
//       if (rawId is int) {
//         driverId = rawId;
//       } else if (rawId is String) {
//         driverId = int.tryParse(rawId);
//       }
//     }

//     if (driverId == null) {
//         debugPrint("ERROR: Data driver tidak punya ID/PK. Data: $driver");
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Error: Driver ID missing. Please ensure PWS deployment is updated.'),
//               backgroundColor: Colors.red,
//             ),
//         );
//         return;
//     }

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF1E1E2C),
//         title: Text(
//           'Edit ${driver['full_name']}',
//           style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         content: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildTextField('Podiums', _podiumsController, isNumber: true),
//                 _buildTextField('Points', _pointsController, isNumber: true, isDecimal: true),
//                 _buildTextField('GP Entries', _entriesController, isNumber: true),
//                 _buildTextField('World Champs', _champsController, isNumber: true),
//                 _buildTextField('Highest Race Finish', _highestRaceController),
//                 _buildTextField('Highest Grid Pos', _highestGridController),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             onPressed: () => _updateDriver(driverId!),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Save Changes'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, bool isDecimal = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: isNumber 
//             ? TextInputType.numberWithOptions(decimal: isDecimal) 
//             : TextInputType.text,
//         style: const TextStyle(color: Colors.white),
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: Colors.grey),
//           enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
//           focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
//           filled: true,
//           fillColor: const Color(0xFF252537),
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) return 'Field cannot be empty';
//           return null;
//         },
//       ),
//     );
//   }

//   // --- 4. WIDGETS UI ---

//   Widget _buildManagementCard(String title, IconData icon, Color color, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [color.withOpacity(0.8), color],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.3),
//               blurRadius: 12,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 36, color: Colors.white.withOpacity(0.9)),
//               const SizedBox(height: 12),
//               Text(
//                 title,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   height: 1.2,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTotalDriversCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1E1E2C),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.green.withOpacity(0.3)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.green.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.green.withOpacity(0.2),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.people_alt_outlined,
//               color: Colors.green,
//               size: 32,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Total Drivers',
//                 style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w500),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 '${_drivers.length}',
//                 style: GoogleFonts.inter(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem(String label, String value) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         Text(
//           label,
//           style: const TextStyle(color: Colors.grey, fontSize: 12),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         backgroundColor: Color(0xFF15151E),
//         body: Center(child: CircularProgressIndicator(color: Color(0xFFE10600))),
//       );
//     }

//     if (!_isAdmin) {
//         return const Scaffold(
//             backgroundColor: Color(0xFF15151E),
//             body: Center(child: Text("Access Denied", style: TextStyle(color: Colors.white))),
//         );
//     }

//     return Scaffold(
//       backgroundColor: const Color(0xFF15151E),
//       appBar: AppBar(
//         title: Text('Manage Drivers', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
//         backgroundColor: const Color(0xFFE10600),
//         leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _fetchDrivers,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // HEADER CARD
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFFE10600), Color(0xFFFF1E00)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFFE10600).withOpacity(0.3),
//                       blurRadius: 20,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Drivers Database',
//                       style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Edit driver statistics and information.',
//                       style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
//                     ),
//                   ],
//                 ),
//               ),
              
//               const SizedBox(height: 24),

//               // --- QUICK ACTIONS GRID ---
//               Text(
//                 'Quick Actions',
//                 style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//               ),
//               const SizedBox(height: 16),
//               GridView.count(
//                 crossAxisCount: 2,
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 mainAxisSpacing: 16,
//                 crossAxisSpacing: 16,
//                 childAspectRatio: 1.1, 
//                 children: [
//                   _buildManagementCard(
//                     'User\nManagement',
//                     Icons.people,
//                     Colors.blue,
//                     () {
//                       Navigator.push(
//                         context, 
//                         MaterialPageRoute(builder: (context) => const ManageUsersScreen()),
//                       );
//                     },
//                   ),
//                   _buildManagementCard(
//                     'Driver\nManagement',
//                     Icons.directions_car,
//                     Colors.green,
//                     () {
//                       // Already Here
//                     },
//                   ),
//                   _buildManagementCard(
//                     'Team\nManagement',
//                     Icons.groups,
//                     Colors.purple,
//                     () {
//                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Team management coming soon')));
//                     },
//                   ),
//                   _buildManagementCard(
//                     'Race\nResults',
//                     Icons.emoji_events,
//                     Colors.orange,
//                     () {
//                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Race results management coming soon')));
//                     },
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 24),

//               // STATISTIK TOTAL DRIVERS
//               _buildTotalDriversCard(),

//               const SizedBox(height: 24),

//               Text(
//                 'Driver List',
//                 style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//               ),
//               const SizedBox(height: 16),

//               // DRIVERS LIST
//               if (_drivers.isEmpty)
//                 const Center(child: Padding(
//                   padding: EdgeInsets.all(20.0),
//                   child: Text("No drivers found", style: TextStyle(color: Colors.grey)),
//                 ))
//               else
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: _drivers.length,
//                   itemBuilder: (context, index) {
//                     final driver = _drivers[index];
//                     final teamName = driver['team'] is String ? driver['team'] : (driver['team']?['name'] ?? 'N/A');
                    
//                     return Card(
//                       color: const Color(0xFF1E1E2C),
//                       margin: const EdgeInsets.only(bottom: 12),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 CircleAvatar(
//                                   backgroundColor: const Color(0xFF252537),
//                                   // FOTO DIHAPUS - Hanya nomor driver
//                                   child: Text(
//                                     driver['number']?.toString() ?? '#',
//                                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         driver['full_name'] ?? 'Unknown',
//                                         style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
//                                       ),
//                                       Text(
//                                         teamName,
//                                         style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.edit, color: Colors.blue),
//                                   onPressed: () => _showEditDialog(driver),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 12),
//                             const Divider(color: Colors.white10),
//                             const SizedBox(height: 8),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 _buildStatItem('Points', driver['points']?.toString() ?? '0'),
//                                 _buildStatItem('Podiums', driver['podiums']?.toString() ?? '0'),
//                                 _buildStatItem('Entries', driver['grands_prix_entered']?.toString() ?? '0'),
//                                 _buildStatItem('Champs', driver['world_championships']?.toString() ?? '0'),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
                
//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }