import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/parking_provider.dart';
import '../widgets/MapaNavegacion.dart';

class SectionDetailScreen extends StatelessWidget {
  final String sectionId;

  const SectionDetailScreen({super.key, required this.sectionId});

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
            Text("Zona $sectionId", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B))),
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
                _buildResumenBadge(Colors.green, libres, "Disponibles"),
                const SizedBox(width: 15),
                _buildResumenBadge(Colors.red.shade300, total - libres, "Ocupados"),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: espaciosZona.isEmpty
                ? const Center(child: Text("No hay espacios cargados"))
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
                return _buildClientCard(context, espaciosZona[index], parkingProvider);
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

  //tarjeta del cliente
  Widget _buildClientCard(BuildContext context, dynamic espacio, ParkingProvider provider) {
    bool isLibre = espacio.estado == 'LIBRE';

    Color colorBorde;
    Color colorIcono;
    Color colorFondo;
    IconData icono;
    String textoEstado;

    switch (espacio.estado) {
      case 'LIBRE':
        colorBorde = Colors.green;
        colorIcono = Colors.green;
        colorFondo = Colors.white;
        icono = Icons.local_parking;
        textoEstado = "DISPONIBLE";
        break;
      case 'RESERVADO':
        colorBorde = Colors.orange;
        colorIcono = Colors.orange;
        colorFondo = Colors.orange.shade50;
        icono = Icons.access_time_filled;
        textoEstado = "RESERVADO";
        break;
      case 'OCUPADO':
        colorBorde = Colors.red;
        colorIcono = Colors.red;
        colorFondo = Colors.red.shade50;
        icono = Icons.block;
        textoEstado = "OCUPADO";
        break;
      case 'MANTENIMIENTO':
        colorBorde = Colors.grey;
        colorIcono = Colors.grey;
        colorFondo = Colors.grey.shade100;
        icono = Icons.build;
        textoEstado = "MANTENIMIENTO";
        break;
      default:
        colorBorde = Colors.grey;
        colorIcono = Colors.grey;
        colorFondo = Colors.white;
        icono = Icons.help;
        textoEstado = espacio.estado;
    }

    return InkWell(
      onTap: isLibre ? () => _mostrarDialogoReserva(context, espacio, provider) : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: colorFondo,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: colorBorde,
              width: isLibre ? 2 : 1.5
          ),
          boxShadow: [
            if (isLibre)
              BoxShadow(color: Colors.green.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
          ],
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                espacio.identificador,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black87
                )
            ),

            const SizedBox(height: 4),

            Icon(icono, size: 26, color: colorIcono),

            const SizedBox(height: 4),

            FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                    color: colorIcono.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4)
                ),
                child: Text(
                    textoEstado,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: colorIcono
                    )
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  //reservas
  void _mostrarDialogoReserva(BuildContext context, dynamic espacio, ParkingProvider provider) {
    final TextEditingController horasController = TextEditingController(text: "1");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.timer, color: Colors.blueAccent),
            const SizedBox(width: 10),
            Text("Reservar ${espacio.identificador}", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Duración de la reserva:", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            TextField(
              controller: horasController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              maxLength: 2,
              decoration: InputDecoration(
                  counterText: "",
                  suffixText: "horas",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) return newValue;
                  final intValue = int.tryParse(newValue.text);
                  if (intValue != null && intValue >= 1 && intValue <= 24) {
                    return newValue;
                  }
                  return oldValue;
                }),
              ],
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              onPressed: () async {
                int horas = int.tryParse(horasController.text) ?? 1;
                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)), SizedBox(width: 15), Text("Procesando reserva...")]),
                      duration: Duration(seconds: 1),
                    )
                );

                Map<String, dynamic> resultado = await provider.reservarEspacio(espacio.id, horas);

                if (context.mounted) {
                  if (resultado['success'] == true) {
                    _mostrarMapaExito(context, espacio.identificador, resultado['qr']);
                  } else {
                    _mostrarError(context, 'Ya tienes una reserva activa');
                  }
                }
              },
              child: const Text("CONFIRMAR RESERVA")
          )
        ],
      ),
    );
  }

  void _mostrarMapaExito(BuildContext context, String identificadorEspacio, String qrDataString) {
    String letraZona = identificadorEspacio[0].toUpperCase();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        contentPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              backgroundColor: Colors.green,
              radius: 30,
              child: Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 15),
            const Text("¡Reserva Exitosa!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 5),
            Text("Espacio asignado: $identificadorEspacio", style: const TextStyle(fontSize: 18, color: Colors.blueAccent, fontWeight: FontWeight.bold)),

            const Divider(height: 30),

            // qr
            const Text("Código de Acceso", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(10)),
              child: QrImageView(
                data: qrDataString,
                version: QrVersions.auto,
                size: 160.0,
                backgroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            //mapa
            const Align(alignment: Alignment.centerLeft, child: Text("Ruta de llegada:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
            const SizedBox(height: 8),
            Container(
              height: 140,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: MapaNavegacion(zonaDestino: letraZona)
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              label: const Text("LISTO, VOY EN CAMINO"),
            ),
          )
        ],
      ),
    );
  }

  void _mostrarError(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.orange), SizedBox(width: 10), Text("Atención")]),
        content: Text(mensaje),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ENTENDIDO"))
        ],
      ),
    );
  }
}