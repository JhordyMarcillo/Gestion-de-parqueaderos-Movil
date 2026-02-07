import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Necesario para mostrar el QR guardado
import '../providers/parking_provider.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ParkingProvider>(context, listen: false).cargarMisReservas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final parkingProvider = Provider.of<ParkingProvider>(context);
    final reservas = parkingProvider.misReservas;

    // Ordenar: Las más recientes primero
    reservas.sort((a, b) => b['id'].compareTo(a['id']));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Fondo Slate suave
      appBar: AppBar(
        title: const Text("Mis Tickets", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B))),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: reservas.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
              child: Icon(Icons.confirmation_number_outlined, size: 60, color: Colors.blue.shade200),
            ),
            const SizedBox(height: 20),
            const Text("No tienes reservas activas.", style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Ir a Reservar"),
            )
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () async => await parkingProvider.cargarMisReservas(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reservas.length,
          itemBuilder: (context, index) {
            return _buildTicketCard(context, reservas[index], parkingProvider);
          },
        ),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, dynamic reserva, ParkingProvider provider) {
    final espacio = reserva['espacio'];
    final String estado = reserva['estado']; // PENDIENTE, EN_CURSO, CANCELADA, FINALIZADA
    final String? qrCode = reserva['qr'] ?? reserva['codigoQr']; // Aseguramos compatibilidad de nombres

    // Configuración visual según estado
    Color colorEstado;
    Color colorFondo;
    String textoEstado;
    IconData iconEstado;

    switch (estado) {
      case 'PENDIENTE':
        colorEstado = Colors.green;
        colorFondo = Colors.white;
        textoEstado = "LISTO PARA ENTRAR";
        iconEstado = Icons.vpn_key;
        break;
      case 'EN_CURSO':
        colorEstado = Colors.blue;
        colorFondo = Colors.blue.shade50;
        textoEstado = "AUTO DENTRO";
        iconEstado = Icons.local_parking;
        break;
      case 'CANCELADA':
        colorEstado = Colors.red;
        colorFondo = Colors.grey.shade100;
        textoEstado = "CANCELADA";
        iconEstado = Icons.cancel;
        break;
      default:
        colorEstado = Colors.grey;
        colorFondo = Colors.white;
        textoEstado = estado;
        iconEstado = Icons.info;
    }

    // Formateo seguro de hora
    String horaInicio = "00:00";
    try {
      final fecha = DateTime.parse(reserva['fechaInicio']);
      horaInicio = "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      horaInicio = "--:--";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: estado == 'PENDIENTE' ? Colors.green.withOpacity(0.3) : Colors.transparent),
      ),
      child: Column(
        children: [
          // 1. CABECERA DEL TICKET
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: colorEstado.withOpacity(0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(iconEstado, size: 16, color: colorEstado),
                    const SizedBox(width: 8),
                    Text(textoEstado, style: TextStyle(fontWeight: FontWeight.bold, color: colorEstado, fontSize: 12)),
                  ],
                ),
                Text("#${reserva['id']}", style: TextStyle(color: colorEstado, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // 2. CUERPO DEL TICKET
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("ESPACIO ASIGNADO", style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(
                        espacio['identificador'],
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("HORA ENTRADA", style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(
                        horaInicio,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. SEPARADOR (Línea punteada simulada)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, color: Colors.grey.shade300, thickness: 1),
          ),

          // 4. ACCIONES
          if (estado != 'CANCELADA' && estado != 'FINALIZADA')
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // BOTÓN QR (Solo si está pendiente o en curso)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _mostrarQR(context, qrCode, espacio['identificador']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // Estilo "Apple Wallet"
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.qr_code, size: 18),
                      label: const Text("VER CÓDIGO QR"),
                    ),
                  ),

                  // BOTÓN CANCELAR (Solo si es PENDIENTE)
                  if (estado == 'PENDIENTE') ...[
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () => _confirmarCancelacion(context, provider, reserva['id']),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.delete_outline),
                      tooltip: "Cancelar Reserva",
                    )
                  ]
                ],
              ),
            ),
        ],
      ),
    );
  }

  // --- MODAL PARA VER EL QR ---
  void _mostrarQR(BuildContext context, String? qrData, String espacioId) {
    if (qrData == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Pase de Entrada", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 5),
            Text("Espacio $espacioId", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12)
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CERRAR"),
          )
        ],
      ),
    );
  }

  // --- LÓGICA DE CANCELACIÓN ---
  Future<void> _confirmarCancelacion(BuildContext context, ParkingProvider provider, int idReserva) async {
    bool confirm = await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("¿Cancelar reserva?"),
          content: const Text("Perderás tu lugar asegurado."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("VOLVER")),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("SÍ, CANCELAR")
            ),
          ],
        )
    ) ?? false;

    if (confirm) {
      await provider.cancelarReserva(idReserva);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reserva cancelada correctamente")));
      }
    }
  }
}