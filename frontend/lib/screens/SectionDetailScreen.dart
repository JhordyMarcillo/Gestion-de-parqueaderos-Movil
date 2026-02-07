import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/parking_provider.dart';
import '../widgets/MapaNavegacion.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text("Zona $sectionId"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Cabecera de la zona
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 40, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Estás viendo el detalle de la Zona $sectionId. Selecciona un espacio.",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
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
                return _buildEspacioCard(context, espacio, parkingProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEspacioCard(BuildContext context, dynamic espacio, ParkingProvider provider) {
    Color color = Colors.grey;
    if (espacio.estado == 'LIBRE') color = Colors.green.shade100;
    if (espacio.estado == 'OCUPADO') color = Colors.red.shade100;
    if (espacio.estado == 'RESERVADO') color = Colors.orange.shade100;

    return InkWell(
      onTap: espacio.estado == 'LIBRE'
          ? () => _mostrarDialogoReserva(context, espacio, provider)
          : null,
      child: Container(
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2,2))]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(espacio.identificador, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(espacio.estado, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoReserva(BuildContext context, dynamic espacio, ParkingProvider provider) {
    final TextEditingController horasController = TextEditingController(text: "1");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Reservar ${espacio.identificador}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Ingresa duración (1 - 24h):"),
            const SizedBox(height: 10),
            TextField(
              controller: horasController,
              keyboardType: TextInputType.number,
              maxLength: 2,
              decoration: const InputDecoration(
                hintText: "Ej: 2",
                counterText: "",
                border: OutlineInputBorder(),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) return newValue;
                  final intValue = int.tryParse(newValue.text);
                  if (intValue != null && intValue >= 1 && intValue <= 24) {
                    return newValue; // Valor válido
                  }
                  return oldValue; // Rechazar valor fuera de rango
                }),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCELAR")),
          ElevatedButton(
              onPressed: () async {
                int horas = int.tryParse(horasController.text) ?? 1;
                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Procesando...")));

                Map<String, dynamic> resultado = await provider.reservarEspacio(espacio.id, horas);

                if (context.mounted) {
                  if (resultado['success'] == true) {
                    _mostrarMapaExito(context, espacio.identificador, resultado['qr']);
                  } else {
                    _mostrarError(context, resultado['message']);
                  }
                }
              },
              child: const Text("CONFIRMAR")
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
        contentPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("¡Reserva Exitosa!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
            const Divider(),
            const Text("Escanea este código en la entrada:", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 15),

            //QR
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(10)
              ),
              child: QrImageView(
                data: qrDataString,
                version: QrVersions.auto,
                size: 180.0,
                backgroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),
            Text("Espacio asignado: $identificadorEspacio", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),

            SizedBox(
                height: 150,
                child: MapaNavegacion(zonaDestino: letraZona)
            ),

          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
              label: const Text("Voy en camino"),
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
        title: const Text("Atención"),
        content: Text("Ya tienes una reserva activa."),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
      ),
    );
  }
}