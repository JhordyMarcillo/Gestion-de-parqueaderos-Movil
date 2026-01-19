import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/parking_provider.dart';
import 'login_screen.dart';
import './AdminSectionDetailScreen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ParkingProvider>(context, listen: false).cargarEspacios();
    });
  }

  int _contar(String letra, String estado, List<dynamic> espacios) {
    return espacios.where((e) =>
    e.identificador.startsWith(letra) && e.estado == estado
    ).length;
  }

  @override
  Widget build(BuildContext context) {
    final parkingProvider = Provider.of<ParkingProvider>(context);
    final espacios = parkingProvider.espacios;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("PANEL DE CONTROL"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
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
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildZonaCard(context, "A", Colors.green, espacios),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text("ENTRADA ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),

            Expanded(
              flex: 5,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Expanded(child: _buildZonaCard(context, "C", Colors.indigo, espacios)),
                        const SizedBox(height: 10),
                        Expanded(child: _buildZonaCard(context, "D", Colors.brown, espacios)),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    flex: 1,
                    child: _buildZonaCard(context, "B", Colors.cyan, espacios, isVertical: true),
                  ),
                ],
              ),
            ),

            const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Text(" ENTRADA", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () => parkingProvider.cargarEspacios(),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildZonaCard(BuildContext context, String letra, Color colorBase, List<dynamic> espacios, {bool isVertical = false}) {
    int libres = _contar(letra, "LIBRE", espacios);
    int ocupados = _contar(letra, "OCUPADO", espacios);
    int reservados = _contar(letra, "RESERVADO", espacios);
    int mant = _contar(letra, "MANTENIMIENTO", espacios);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminSectionDetailScreen(sectionId: letra)),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: colorBase, width: 3),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: colorBase.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))
            ]
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: isVertical
            ? Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("ZONA", style: TextStyle(color: colorBase, fontWeight: FontWeight.bold, fontSize: 14)),
            Text(letra, style: TextStyle(color: colorBase, fontWeight: FontWeight.bold, fontSize: 36)),
            const Divider(),
            _buildCounterVertical(Colors.green, libres, "Lib"),
            _buildCounterVertical(Colors.red, ocupados, "Ocp"),
            _buildCounterVertical(Colors.grey, mant, "Mnt"),
          ],
        )
            : Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("ZONA $letra",
                        style: TextStyle(color: colorBase, fontWeight: FontWeight.bold, fontSize: 30)
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildCounterRow(Colors.green, libres, "Libres"),
                const SizedBox(height: 4),
                _buildCounterRow(Colors.red, ocupados, "Ocupados"),
                const SizedBox(height: 4),
                _buildCounterRow(Colors.orange, reservados, "Reserv"),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCounterRow(Color color, int count, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(width: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: Text("$count", style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildCounterVertical(Color color, int count, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.2)),
          child: Text("$count", style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12)),
        ),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        const SizedBox(height: 4),
      ],
    );
  }
}