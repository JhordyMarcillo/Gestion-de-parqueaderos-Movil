import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/parking_provider.dart';
import '../providers/auth_provider.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Timer? _timer;

  void _mostrarDialogoReserva(BuildContext context, dynamic espacio) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Reservar ${espacio.identificador}"),
        content: const Text("¿Deseas reservar este espacio por 1 hora?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cerrar
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              // AQUÍ LLAMAREMOS AL BACKEND LUEGO
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Funcionalidad de Reserva: ¡Próximamente!"))
              );
            },
            child: const Text("Reservar"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // 1. Carga inicial (con spinner)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final parkingProvider = Provider.of<ParkingProvider>(context, listen: false);
      parkingProvider.cargarEspacios(checkBackground: false);

      // 2. Iniciar el ciclo automático (cada 3 segundos)
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        // Llamamos en modo "background" para que no salga el spinner
        parkingProvider.cargarEspacios(checkBackground: true);
      });
    });
  }

  @override
  void dispose() {
    // 3. ¡MUY IMPORTANTE! Matar el timer cuando salimos de la pantalla
    // Si no haces esto, la app seguirá pidiendo datos aunque la cierres.
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parkingProvider = Provider.of<ParkingProvider>(context);
    final size = MediaQuery.of(context).size; // Para cálculos de pantalla
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Parking"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: size.height, // Aseguramos que ocupe la pantalla
          padding: const EdgeInsets.all(16.0),
          child: Column( // <--- Este es el Column que te daba error
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Estado en Tiempo Real",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Leyenda de colores
              Row(
                children: [
                  _buildLeyenda(Colors.green, "Libre"),
                  const SizedBox(width: 15),
                  _buildLeyenda(Colors.red, "Ocupado"),
                ],
              ),
              const SizedBox(height: 20),

              // GRILLA DE ESPACIOS
              // Usamos Expanded para que ocupe el resto de la pantalla
              Expanded(
                child: parkingProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 columnas
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: parkingProvider.espacios.length,
                  itemBuilder: (context, index) {
                    final espacio = parkingProvider.espacios[index];
                    return Card(
                      // ... tu código de la tarjeta ...
                        color: espacio.estado == 'OCUPADO' ? Colors.red.shade100 : Colors.green.shade100,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(espacio.identificador),
                              // ...
                            ]
                        )
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => parkingProvider.cargarEspacios(),
        child: const Icon(Icons.refresh),
      ),
    );
  }

  // Widget auxiliar para la leyenda
  Widget _buildLeyenda(Color color, String texto) {
    return Row(
      children: [
        CircleAvatar(backgroundColor: color, radius: 8),
        const SizedBox(width: 5),
        Text(texto),
      ],
    );
  }
}