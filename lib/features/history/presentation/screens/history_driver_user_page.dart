import 'package:flutter/material.dart';
import '../../data/history_api.dart';
import '../../data/models/driver_model.dart';
import '../widgets/driver_carousel.dart';
import '../widgets/driver_filter.dart';
import '../widgets/driver_table.dart';

import 'package:pittalk_mobile/mainpage/presentation/widgets/sidebar.dart';
import 'package:go_router/go_router.dart';

class DriverUserPage extends StatefulWidget {
  const DriverUserPage({super.key});

  @override
  State<DriverUserPage> createState() => _DriverUserPageState();
}

class _DriverUserPageState extends State<DriverUserPage> {
  final HistoryApi api = HistoryApi();
  List<Driver> allDrivers = [];
  List<Driver> displayed = [];
  List<Driver> newest = [];
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

      final latest = List<Driver>.from(drivers);
      latest.sort((a, b) => b.id.compareTo(a.id));
      newest = latest.take(3).toList();

      setState(() {
        allDrivers = drivers;
        displayed = List.from(drivers);
        loading = false;
      });
    } catch (e) {
      debugPrint("Error fetch drivers: $e");
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
        title: const Text("Driver History", style: TextStyle(color: Colors.white)),
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
                    "Driver History Overview",
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  DriverCarousel(drivers: newest),

                  const SizedBox(height: 20),

                  DriverFilter(
                    allDrivers: allDrivers,
                    onChanged: (list) => setState(() => displayed = list),
                    onReset: resetFilter,
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: DriverTable(drivers: displayed, isAdmin: false),
                  ),
                ],
              ),
            ),
    );
  }
}
