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

      // Pake SingleChildScrollView buat bisa scroll horizontal
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 50,
          dataRowHeight: 50,

          // Spacing biar center
          columnSpacing: 40,
          horizontalMargin: 24,

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
                DataCell(Text("${i + 1}",
                        style: const TextStyle(color: Colors.white))),
                DataCell(Text(w.grandPrix,
                        style: TextStyle(color: Colors.yellowAccent.shade700))),
                DataCell(Text(w.dateString,
                        style: TextStyle(color: Colors.yellowAccent.shade400))),
                DataCell(Text(w.winnerName,
                        style: TextStyle(color: Colors.yellowAccent.shade100))),
                DataCell(Text(w.car,
                        style: const TextStyle(color: Colors.white70))),
                DataCell(Text(w.laps?.toString() ?? "-",
                        style: const TextStyle(color: Colors.white70))),
                DataCell(Text(w.time,
                        style: const TextStyle(color: Colors.white70))),

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
                                  title: const Text("Delete Winner?"),
                                  content:
                                      Text("Are you sure you want to delete ${w.winner}?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Cancel")),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Delete")),
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
