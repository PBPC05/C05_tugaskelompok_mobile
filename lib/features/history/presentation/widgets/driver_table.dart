import 'package:flutter/material.dart';
import '../../data/models/driver_model.dart';

class DriverTable extends StatelessWidget {
  final List<Driver> drivers;
  final bool isAdmin;
  final void Function(Driver)? onEdit;
  final Future<void> Function(int)? onDelete;

  const DriverTable({
    super.key,
    required this.drivers,
    required this.isAdmin,
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 50,
          dataRowHeight: 50,
          columnSpacing: 40,
          horizontalMargin: 24,
          headingTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          columns: [
            const DataColumn(label: Center(child: Text("#"))),
            const DataColumn(label: Center(child: Text("Driver"))),
            const DataColumn(label: Center(child: Text("Nationality"))),
            const DataColumn(label: Center(child: Text("Car"))),
            const DataColumn(label: Center(child: Text("Points"))),
            const DataColumn(label: Center(child: Text("Podiums"))),
            const DataColumn(label: Center(child: Text("Year"))),
            if (isAdmin)
              const DataColumn(label: Center(child: Text("Actions"))),
          ],
          rows: List.generate(drivers.length, (i) {
            final d = drivers[i];

            return DataRow(
              color: MaterialStatePropertyAll(
                i % 2 == 0 ? Colors.black45 : Colors.black26,
              ),
              cells: [
                DataCell(Center(child: Text("${i + 1}", style: const TextStyle(color: Colors.white)))),
                DataCell(Center(child: Text(d.driverName, style: const TextStyle(color: Colors.redAccent)))),
                DataCell(Center(child: Text(d.nationality, style: const TextStyle(color: Colors.white70)))),
                DataCell(Center(child: Text(d.car, style: const TextStyle(color: Colors.white70)))),
                DataCell(Center(child: Text("${d.points}", style: const TextStyle(color: Colors.redAccent)))),
                DataCell(Center(child: Text("${d.podiums}", style: const TextStyle(color: Colors.redAccent)))),
                DataCell(Center(child: Text("${d.year}", style: const TextStyle(color: Colors.white70)))),

                if (isAdmin)
                  DataCell(
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => onEdit?.call(d),
                            child: const Text(
                              "Edit",
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Delete Driver?"),
                                  content: Text(
                                    "Are you sure you want to delete ${d.driverName}?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.redAccent),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (ok == true && onDelete != null) {
                                await onDelete!(d.id);
                              }
                            },
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.redAccent),
                            ),
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
