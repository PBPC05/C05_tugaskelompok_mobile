import 'package:flutter/material.dart';
import '../../data/history_api.dart';
import '../../data/models/driver_model.dart';

import '../widgets/driver_carousel.dart';
import '../widgets/driver_filter.dart';
import '../widgets/driver_add_form.dart';
import '../widgets/driver_edit_modal.dart';
import '../widgets/driver_table.dart';

import 'package:pittalk_mobile/mainpage/presentation/widgets/sidebar.dart';
import 'package:go_router/go_router.dart';

class DriverAdminPage extends StatefulWidget {
  const DriverAdminPage({super.key});

  @override
  State<DriverAdminPage> createState() => _DriverAdminPageState();
}

class _DriverAdminPageState extends State<DriverAdminPage> {
  final HistoryApi api = HistoryApi();
  List<Driver> allDrivers = [];
  List<Driver> displayed = [];
  Driver? newest;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchDrivers();
  }

  Future<void> fetchDrivers() async {
    setState(() => loading = true);
    try {
      final drivers = await api.fetchDrivers();

      final latest = List<Driver>.from(drivers)
        ..sort((a, b) => b.id.compareTo(a.id));
      newest = latest.isNotEmpty ? latest.first : null;

      setState(() {
        allDrivers = drivers;
        displayed = List.from(drivers);
        loading = false;
      });
    } catch (e) {
      debugPrint("Error fetch drivers admin: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  void resetFilter() {
    setState(() => displayed = List.from(allDrivers));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Driver Admin", style: TextStyle(color: Colors.white)),
      ),

      // drawer: PitTalkSidebar(
      //   currentRoute: GoRouterState.of(context).uri.toString(),
      // ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Driver Management",
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  if (newest != null)
                    DriverCarousel(
                      drivers: [newest!],
                      showControls: false,  // seperti yg ada di winner admin
                    ),

                  const SizedBox(height: 16),

                  DriverAddForm(onAdded: fetchDrivers),

                  const SizedBox(height: 20),

                  DriverFilter(
                    allDrivers: allDrivers,
                    onChanged: (list) => setState(() => displayed = list),
                    onReset: resetFilter,
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: DriverTable(
                      drivers: displayed,
                      isAdmin: true,
                      onEdit: (d) {
                        showDialog(
                          context: context,
                          builder: (_) => DriverEditModal(
                            driver: d,
                            onUpdated: fetchDrivers,
                          ),
                        );
                      },
                      onDelete: (id) async {
                        await api.deleteDriver(id);
                        fetchDrivers();
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
