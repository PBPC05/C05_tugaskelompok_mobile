import 'package:flutter/material.dart';
import '../../data/models/driver_model.dart';

class DriverTable extends StatelessWidget {
  final List<Driver> drivers;
  final bool isAdmin;
  final Function(Driver)? onEdit;
  final Function(int)? onDelete;

  const DriverTable({
    super.key,
    required this.drivers,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 40,
        columns: const [
          DataColumn(label: Text("ID", style: TextStyle(color: Colors.white))),
          DataColumn(label: Text("Driver", style: TextStyle(color: Colors.white))),
          DataColumn(label: Text("Nationality", style: TextStyle(color: Colors.white))),
          DataColumn(label: Text("Car", style: TextStyle(color: Colors.white))),
          DataColumn(label: Text("Points", style: TextStyle(color: Colors.white))),
          DataColumn(label: Text("Podiums", style: TextStyle(color: Colors.white))),
          DataColumn(label: Text("Year", style: TextStyle(color: Colors.white))),
          DataColumn(label: Text("Actions", style: TextStyle(color: Colors.white))),
        ],
        rows: drivers.map(
          (driver) {
            return DataRow(
              color: MaterialStatePropertyAll(Colors.black54),
              cells: [
                DataCell(Text("${driver.id}", style: const TextStyle(color: Colors.white))),
                DataCell(Text(driver.driverName, style: const TextStyle(color: Colors.white))),
                DataCell(Text(driver.nationality, style: const TextStyle(color: Colors.white))),
                DataCell(Text(driver.car, style: const TextStyle(color: Colors.white))),
                DataCell(Text("${driver.points}", style: const TextStyle(color: Colors.yellowAccent))),
                DataCell(Text("${driver.podiums}", style: const TextStyle(color: Colors.yellowAccent))),
                DataCell(Text("${driver.year}", style: const TextStyle(color: Colors.white))),
                DataCell(
                  isAdmin
                      ? Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () => onEdit?.call(driver),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => onDelete?.call(driver.id),
                            ),
                          ],
                        )
                      : const SizedBox(),
                ),
              ],
            );
          },
        ).toList(),
      ),
    );
  }
}
