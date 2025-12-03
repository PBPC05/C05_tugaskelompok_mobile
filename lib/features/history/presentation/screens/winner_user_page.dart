import 'package:flutter/material.dart';
import '../../data/models/winner_model.dart';
import '../../data/history_api.dart';
import '../widgets/winner_carousel.dart';
import '../widgets/winner_filter.dart';
import '../widgets/winner_table.dart';

import 'package:pittalk_mobile/mainpage/presentation/widgets/sidebar.dart';
import 'package:go_router/go_router.dart';

class WinnerUserPage extends StatefulWidget {
  const WinnerUserPage({super.key});
  @override
  State<WinnerUserPage> createState() => _WinnerUserPageState();
}

class _WinnerUserPageState extends State<WinnerUserPage> {
  final HistoryApi api = HistoryApi();
  List<Winner> allWinners = [];
  List<Winner> displayed = [];
  List<Winner> newest = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchWinners();
  }

  Future<void> fetchWinners() async {
    setState(() => loading = true);
    try {
      final winners = await api.fetchWinners();
      // newest = 3 berdasarkan id terbesar (ambil terakhir)
      final latest = List<Winner>.from(winners);
      latest.sort((a, b) => b.id.compareTo(a.id));
      newest = latest.take(3).toList();

      setState(() {
        allWinners = winners;
        displayed = List.from(winners);
        loading = false;
      });
    } catch (e) {
      // tampilkan console error saja
      debugPrint("Error fetch winners (user): $e");
      if (mounted) setState(() => loading = false);
    }
  }

  void resetFilter() {
    setState(() => displayed = List.from(allWinners));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Grand Prix Winners", style: TextStyle(color: Colors.white)),
      ),

      drawer: PitTalkSidebar(
        currentRoute: GoRouterState.of(context).uri.toString(),
      ),
    
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    "Grand Prix History",
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Carousel (3 terbaru)
                  WinnerCarousel(winners: newest, imageProxy: api.proxiedImage),

                  const SizedBox(height: 20),

                  // Filter
                  WinnerFilter(
                    allWinners: allWinners,
                    onChanged: (list) => setState(() => displayed = list),
                    onReset: resetFilter,
                  ),

                  const SizedBox(height: 20),

                  // Table (user: tanpa actions)
                  Center(child: WinnerTable(winners: displayed, isAdmin: false)),
                ],
              ),
            ),
    );
  }
}
