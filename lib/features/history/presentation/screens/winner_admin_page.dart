import 'package:flutter/material.dart';
import '../../data/history_api.dart';
import '../../data/models/winner_model.dart';
import '../widgets/winner_table.dart';
import '../widgets/winner_add_form.dart';
import '../widgets/winner_edit_modal.dart';
import '../widgets/winner_filter.dart';
import '../widgets/winner_carousel.dart';

import 'package:pittalk_mobile/mainpage/presentation/widgets/sidebar.dart';
import 'package:go_router/go_router.dart';

class WinnerAdminPage extends StatefulWidget {
  const WinnerAdminPage({super.key});
  @override
  State<WinnerAdminPage> createState() => _WinnerAdminPageState();
}

class _WinnerAdminPageState extends State<WinnerAdminPage> {
  final HistoryApi api = HistoryApi();
  List<Winner> allWinners = [];
  List<Winner> displayed = [];
  Winner? newest;
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
      // sort sudah dilakukan di API, pilih newest berdasarkan id terbesar
      final latest = List<Winner>.from(winners)..sort((a, b) => b.id.compareTo(a.id));
      newest = latest.isNotEmpty ? latest.first : null;

      setState(() {
        allWinners = winners;
        displayed = List.from(winners);
        loading = false;
      });
    } catch (e) {
      debugPrint("Error fetch winners (admin): $e");
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
        title: const Text("Winner Admin", style: TextStyle(color: Colors.white)),
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
                  const Text("Grand Prix Winner Management", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // Newest card
                  if (newest != null)
                    WinnerCarousel(winners: [newest!], imageProxy: api.proxiedImage, showControls: false),

                  const SizedBox(height: 16),

                  // Add form
                  WinnerAddForm(onAdded: fetchWinners, api: api),

                  const SizedBox(height: 20),

                  // Filter
                  WinnerFilter(allWinners: allWinners, onChanged: (l) => setState(() => displayed = l), onReset: resetFilter),

                  const SizedBox(height: 20),

                  // Table (admin with actions)
                  Center(
                    child: WinnerTable(
                      winners: displayed,
                      isAdmin: true,
                      onEdit: (w) {
                        showDialog(context: context, builder: (_) => WinnerEditModal(winner: w, api: api, onUpdated: fetchWinners));
                      },
                      onDelete: (id) async {
                        await api.deleteWinner(id);
                        fetchWinners();
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
