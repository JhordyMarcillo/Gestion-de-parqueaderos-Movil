import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/parking_provider.dart';
import 'login_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {

  @override
  void initState() {
    super.initState();
    // Cargar los espacios apenas entramos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ParkingProvider>(context, listen: false).cargarEspacios();
    });
  }

  @override
  Widget build(BuildContext context) {
    final parkingProvider = Provider.of<ParkingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Control 🛠️"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Cabecera informativa
          Container(
            padding: const EdgeInsets.all(15),
            color: Colors.orange.shade50,
            child: const Row(
              children: [
                Icon(Icons.touch_app, color: Colors.orange),
                SizedBox(width: 10),
                Expanded(child: Text("Toca un espacio para cambiar su estado.", style: TextStyle(fontSize: 16))),
              ],
            ),
          ),

          // Grilla de espacios
          Expanded(
            child: parkingProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: parkingProvider.espacios.length,
              itemBuilder: (context, index) {
                final espacio = parkingProvider.espacios[index];
                return _buildAdminCard(context, espacio, parkingProvider);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () => parkingProvider.cargarEspacios(),
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, dynamic espacio, ParkingProvider provider) {
    Color colorEstado;
    IconData icono;

    switch (espacio.estado) {
      case 'LIBRE':
        colorEstado = Colors.green.shade100;
        icono = Icons.check_circle_outline;
        break;
      case 'OCUPADO':
        colorEstado = Colors.red.shade100;
        icono = Icons.directions_car;
        break;
      case 'MANTENIMIENTO':
        colorEstado = Colors.grey.shade300;
        icono = Icons.build;
        break;
      default:
        colorEstado = Colors.blue.shade50;
        icono = Icons.help_outline;
    }

    return Card(
      color: colorEstado,
      elevation: 4,
      child: InkWell(
        onTap: () => _mostrarMenuCambioEstado(context, espacio, provider),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                espacio.identificador,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icono, size: 20),
                const SizedBox(width: 5),
                Text(espacio.estado, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 5),
            const Text("Tap para editar ️", style: TextStyle(fontSize: 10, color: Colors.grey)),
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
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Editar Espacio ${espacio.identificador}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text("Marcar como LIBRE"),
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.cambiarEstadoEspacio(espacio.id, "LIBRE");
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.car_rental, color: Colors.red),
                  title: const Text("Marcar como OCUPADO"),
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.cambiarEstadoEspacio(espacio.id, "OCUPADO");
                  },
                ),
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