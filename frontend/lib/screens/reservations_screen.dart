import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Reservas Activas"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: reservas.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.time_to_leave_sharp, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            const Text("No tienes reservas activas.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: reservas.length,
        itemBuilder: (context, index) {
          final reserva = reservas[index];
          final espacio = reserva['espacio'];

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("ESPACIO", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                              espacio['identificador'],
                              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blueAccent)
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text(reserva['estado'], style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const Divider(height: 30),
                  Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.grey),
                      const SizedBox(width: 10),
                      Text("Inicio: ${reserva['fechaInicio'].toString().substring(11, 16)}"), // Hora simple
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          elevation: 0
                      ),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text("CANCELAR RESERVA"),
                      onPressed: () async {
                        bool confirm = await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("¿Cancelar reserva?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("NO")),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("SÍ, CANCELAR")),
                              ],
                            )
                        ) ?? false;

                        if (confirm) {
                          await parkingProvider.cancelarReserva(reserva['id']);
                          if(mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reserva Cancelada")));
                          }
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}