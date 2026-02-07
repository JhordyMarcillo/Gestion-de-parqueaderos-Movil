import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/parking_provider.dart';

class AdminSectionDetailScreen extends StatelessWidget {
  final String sectionId; // "A", "B", "C"...

  const AdminSectionDetailScreen({super.key, required this.sectionId});

  @override
  Widget build(BuildContext context) {
    final parkingProvider = Provider.of<ParkingProvider>(context);

    final espaciosZona = parkingProvider.espacios
        .where((e) => e.identificador.toUpperCase().startsWith(sectionId))
        .toList();

    espaciosZona.sort((a, b) => a.identificador.compareTo(b.identificador));

    return Scaffold(
      appBar: AppBar(
        title: Text("Administrar Zona $sectionId"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            color: Colors.orange.shade50,
            child: const Row(
              children: [
                Icon(Icons.edit_note, color: Colors.orange),
                SizedBox(width: 10),
                Expanded(child: Text("Toca un espacio para modificar su estado")),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: espaciosZona.length,
              itemBuilder: (context, index) {
                final espacio = espaciosZona[index];
                return _buildAdminCard(context, espacio, parkingProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, dynamic espacio, ParkingProvider provider) {
    Color color;
    IconData icono;

    switch (espacio.estado) {
      case 'LIBRE':
        color = Colors.green.shade100;
        icono = Icons.check_circle_outline;
        break;
      case 'OCUPADO':
        color = Colors.red.shade100;
        icono = Icons.directions_car;
        break;
      case 'RESERVADO':
        color = Colors.orange.shade100;
        icono = Icons.access_time_filled;
        break;
      case 'MANTENIMIENTO':
        color = Colors.grey.shade300;
        icono = Icons.build;
        break;
      default:
        color = Colors.white;
        icono = Icons.help;
    }

    return InkWell(
      onTap: () => _mostrarMenuCambioEstado(context, espacio, provider),
      child: Container(
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black26),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(2,2))]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(espacio.identificador, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 5),
            Icon(icono, size: 24, color: Colors.black54),
            const SizedBox(height: 5),
            Text(espacio.estado, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _mostrarMenuCambioEstado(BuildContext context, dynamic espacio, ParkingProvider provider) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            padding: const EdgeInsets.all(20),
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Editar ${espacio.identificador}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Divider(),

                if (espacio.estado != "LIBRE")
                  ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: const Text("Liberar Espacio"),
                    onTap: () {
                      Navigator.pop(ctx);
                      provider.cambiarEstadoEspacio(espacio.id, "LIBRE");
                    },
                  ),

                if (espacio.estado != "OCUPADO")
                  ListTile(
                    leading: const Icon(Icons.car_rental, color: Colors.red),
                    title: const Text("Marcar OCUPADO"),
                    onTap: () {
                      Navigator.pop(ctx);
                      provider.cambiarEstadoEspacio(espacio.id, "OCUPADO");
                    },
                  ),

                if (espacio.estado != "MANTENIMIENTO")
                  ListTile(
                    leading: const Icon(Icons.build, color: Colors.grey),
                    title: const Text("Poner en MANTENIMIENTO"),
                    onTap: () {
                      Navigator.pop(ctx);
                      provider.cambiarEstadoEspacio(espacio.id, "MANTENIMIENTO");
                    },
                  ),
              ],
            ),
          );
        }
    );
  }
}