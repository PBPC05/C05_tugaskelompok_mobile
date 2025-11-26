import 'package:flutter/material.dart';
import '../../data/models/driver_model.dart';
import '../../data/history_api.dart';

import '../widgets/driver_filter.dart';
import '../widgets/driver_table.dart';
import '../widgets/driver_edit_modal.dart';
import '../widgets/driver_add_form.dart';

class HistoryDriverAdminPage extends StatefulWidget {
  const HistoryDriverAdminPage({super.key});

  @override
  State<HistoryDriverAdminPage> createState() => _HistoryDriverAdminPageState();
}

class _HistoryDriverAdminPageState extends State<HistoryDriverAdminPage> {
  final HistoryApi api = HistoryApi();

  List<Driver> allDrivers = [];
  List<Driver> displayedDrivers = [];
  Driver? newestDriver;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDrivers();
  }

  // ============================================================
  // FETCH DRIVERS
  // ============================================================
  Future<void> fetchDrivers() async {
    setState(() => isLoading = true);

    try {
      final drivers = await api.fetchDrivers();

      // Driver terbaru = ID terbesar
      final newest = List<Driver>.from(drivers)
        ..sort((a, b) => b.id.compareTo(a.id));

      setState(() {
        allDrivers = drivers;
        displayedDrivers = drivers;
        newestDriver = newest.isNotEmpty ? newest.first : null;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetch drivers: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  // Reset filter
  void resetFilter() {
    setState(() {
      displayedDrivers = List.from(allDrivers);
    });
  }

  // ============================================================
  // Build UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Driver Admin", style: TextStyle(color: Colors.white)),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === Title ===
                  const Text(
                    "Driver History Management",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // === Newest Driver Card ===
                  if (newestDriver != null) _buildNewestDriverCard(),

                  const SizedBox(height: 20),

                  // === Add Driver Form ===
                  DriverAddForm(onAdded: fetchDrivers),

                  const SizedBox(height: 30),

                  // === Filter ===
                  DriverFilter(
                    allDrivers: allDrivers,
                    onChanged: (filtered) {
                      setState(() => displayedDrivers = filtered);
                    },
                    onReset: resetFilter,
                  ),

                  const SizedBox(height: 20),

                  // === Table ===
                  DriverTable(
                    drivers: displayedDrivers,
                    isAdmin: true,
                    onEdit: (driver) {
                      showDialog(
                        context: context,
                        builder: (_) => DriverEditModal(
                          driver: driver,
                          onUpdated: fetchDrivers,
                        ),
                      );
                    },
                    onDelete: (id) async {
                      await api.deleteDriver(id);
                      fetchDrivers();
                    },
                  ),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // NEWEST DRIVER CARD
  // ============================================================
  Widget _buildNewestDriverCard() {
    final d = newestDriver!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Row(
        children: [
          // FOTO DRIVER
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade800,
              image: d.imageUrl != null && d.imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(api.proxyImage(d.imageUrl)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),

          const SizedBox(width: 16),

          // INFO DRIVER
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.driverName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("Nationality: ${d.nationality}",
                    style: const TextStyle(color: Colors.white70)),
                Text("Car: ${d.car}",
                    style: const TextStyle(color: Colors.white70)),
                Text("Points: ${d.points}",
                    style: const TextStyle(color: Colors.redAccent)),
                Text("Year: ${d.year}",
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
