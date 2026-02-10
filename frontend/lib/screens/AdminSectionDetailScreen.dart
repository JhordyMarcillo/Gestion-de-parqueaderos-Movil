import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/parking_provider.dart';

class AdminSectionDetailScreen extends StatelessWidget {
  final String sectionId;

  const AdminSectionDetailScreen({super.key, required this.sectionId});

  @override
  Widget build(BuildContext context) {
    final parkingProvider = Provider.of<ParkingProvider>(context);

    final espaciosZona = parkingProvider.espacios
        .where((e) => e.identificador.toUpperCase().startsWith(sectionId))
        .toList();

    espaciosZona.sort((a, b) => a.identificador.compareTo(b.identificador));

    int libres = espaciosZona.where((e) => e.estado == 'LIBRE').length;
    int total = espaciosZona.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Gestión Zona $sectionId", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B))),
            Text("$total espacios totales", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            color: Colors.white,
            child: Row(
              children: [
                _buildResumenBadge(Colors.green, libres, "Libres"),
                const SizedBox(width: 15),
                _buildResumenBadge(Colors.red, total - libres, "No Disponibles"),
              ],
            ),
          ),

          const Divider(height: 1),

          //Grid de Espacios
          Expanded(
            child: espaciosZona.isEmpty
                ? const Center(child: Text("No hay espacios en esta zona"))
                : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: espaciosZona.length,
              itemBuilder: (context, index) {
                return _buildAdminCard(context, espaciosZona[index], parkingProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenBadge(Color color, int count, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Text("$count", style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
      ],
    );
  }

  // Tarjeta de Espacio (Refactorizada)
  Widget _buildAdminCard(BuildContext context, dynamic espacio, ParkingProvider provider) {
    Color colorBase;
    Color colorFondo;
    IconData icono;
    String estadoTexto;

    switch (espacio.estado) {
      case 'LIBRE':
        colorBase = Colors.green;
        colorFondo = Colors.white;
        icono = Icons.check_circle_outline;
        estadoTexto = "Libre";
        break;
      case 'OCUPADO':
        colorBase = Colors.red;
        colorFondo = Colors.red.shade50;
        icono = Icons.directions_car;
        estadoTexto = "Ocupado";
        break;
      case 'RESERVADO':
        colorBase = Colors.orange;
        colorFondo = Colors.orange.shade50;
        icono = Icons.access_time_filled;
        estadoTexto = "Reservado";
        break;
      case 'MANTENIMIENTO':
        colorBase = Colors.grey;
        colorFondo = Colors.grey.shade100;
        icono = Icons.build;
        estadoTexto = "Mant.";
        break;
      default:
        colorBase = Colors.black;
        colorFondo = Colors.white;
        icono = Icons.help;
        estadoTexto = "Unknown";
    }

    return InkWell(
      onTap: () => _mostrarMenuCambioEstado(context, espacio, provider),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: colorFondo,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: espacio.estado == 'LIBRE' ? Colors.grey.shade300 : colorBase.withOpacity(0.5),
              width: espacio.estado == 'LIBRE' ? 1 : 2
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Identificador Grande
            Text(
              espacio.identificador,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: espacio.estado == 'LIBRE' ? const Color(0xFF1E293B) : colorBase
              ),
            ),
            const SizedBox(height: 8),
            // Icono de estado
            Icon(icono, size: 28, color: colorBase),
            const SizedBox(height: 8),
            // Texto pequeño de estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorBase.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                estadoTexto,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorBase),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarMenuCambioEstado(BuildContext context, dynamic espacio, ParkingProvider provider) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent, // Para que se vean las esquinas redondeadas
        builder: (ctx) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Se ajusta al contenido
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Text("Editar ${espacio.identificador}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                      child: Text("Actual: ${espacio.estado}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 20),

                // Generación dinámica de opciones
                if (espacio.estado != "LIBRE")
                  _buildActionTile(ctx, "Liberar Espacio", Icons.check_circle, Colors.green, () {
                    provider.cambiarEstadoEspacio(espacio.id, "LIBRE");
                  }),

                if (espacio.estado != "OCUPADO")
                  _buildActionTile(ctx, "Marcar OCUPADO", Icons.car_rental, Colors.red, () {
                    provider.cambiarEstadoEspacio(espacio.id, "OCUPADO");
                  }),

                if (espacio.estado != "MANTENIMIENTO")
                  _buildActionTile(ctx, "Poner en MANTENIMIENTO", Icons.build, Colors.grey, () {
                    provider.cambiarEstadoEspacio(espacio.id, "MANTENIMIENTO");
                  }),

                const SizedBox(height: 10),
              ],
            ),
          );
        }
    );
  }

  Widget _buildActionTile(BuildContext ctx, String title, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: color.withOpacity(0.05),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color.withOpacity(0.8))),
        onTap: () {
          Navigator.pop(ctx);
          onTap();
        },
      ),
    );
  }
}