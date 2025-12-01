import 'package:flutter/material.dart';
import '../../data/models/winner_model.dart';

class WinnerTable extends StatelessWidget {
  final List<Winner> winners;
  final bool isAdmin;
  final void Function(Winner)? onEdit;
  final Future<void> Function(int)? onDelete;

  const WinnerTable({
    super.key,
    required this.winners,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),

      // ==== SCROLLING HORIZONTAL ====
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 50,
          dataRowHeight: 50,

          // ==== SPACING BIAR CENTER ====
          columnSpacing: 40,
          horizontalMargin: 24,

          // ==== TULISAN HEADER NAMPILIN CENTER ====
          headingTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),

          columns: [
            const DataColumn(label: Center(child: Text("#"))),
            const DataColumn(label: Center(child: Text("Grand Prix"))),
            const DataColumn(label: Center(child: Text("Date"))),
            const DataColumn(label: Center(child: Text("Winner"))),
            const DataColumn(label: Center(child: Text("Car"))),
            const DataColumn(label: Center(child: Text("Laps"))),
            const DataColumn(label: Center(child: Text("Time"))),
            if (isAdmin)
              const DataColumn(label: Center(child: Text("Actions"))),
          ],

          rows: List.generate(winners.length, (i) {
            final w = winners[i];

            return DataRow(
              color: MaterialStatePropertyAll(
                i % 2 == 0 ? Colors.black45 : Colors.black26,
              ),

              cells: [
                DataCell(Center(
                    child: Text("${i + 1}",
                        style: const TextStyle(color: Colors.white)))),
                DataCell(Center(
                    child: Text(w.grandPrix,
                        style: TextStyle(color: Colors.yellowAccent.shade700)))),
                DataCell(Center(
                    child: Text(w.dateString,
                        style: TextStyle(color: Colors.yellowAccent.shade400)))),
                DataCell(Center(
                    child: Text(w.winnerName,
                        style: TextStyle(color: Colors.yellowAccent.shade100)))),
                DataCell(Center(
                    child: Text(w.car,
                        style: const TextStyle(color: Colors.white70)))),
                DataCell(Center(
                    child: Text(w.laps?.toString() ?? "-",
                        style: const TextStyle(color: Colors.white70)))),
                DataCell(Center(
                    child: Text(w.time,
                        style: const TextStyle(color: Colors.white70)))),

                if (isAdmin)
                  DataCell(
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => onEdit?.call(w),
                            child: const Text("Edit",
                                style: TextStyle(color: Colors.blueAccent)),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Hapus?"),
                                  content:
                                      const Text("Yakin ingin menghapus data ini?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Batal")),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Hapus")),
                                  ],
                                ),
                              );

                              if (ok == true && onDelete != null) {
                                await onDelete!(w.id);
                              }
                            },
                            child: const Text("Delete",
                                style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
