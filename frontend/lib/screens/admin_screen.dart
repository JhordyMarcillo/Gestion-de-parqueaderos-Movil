import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/parking_provider.dart';
import 'login_screen.dart';
import './AdminSectionDetailScreen.dart';
import './AdminDashboardScreen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final parkingProvider = Provider.of<ParkingProvider>(context, listen: false);
      parkingProvider.cargarEspacios();

      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        parkingProvider.cargarEspacios(checkBackground: true);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _contar(String letra, String estado, List<dynamic> espacios) {
    return espacios.where((e) => e.identificador.startsWith(letra) && e.estado == estado).length;
  }

  @override
  Widget build(BuildContext context) {
    final parkingProvider = Provider.of<ParkingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final espacios = parkingProvider.espacios;

    int totalOcupados = espacios.where((e) => e.estado == 'OCUPADO').length;
    int totalEspacios = espacios.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("PANEL DE CONTROL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B))),
            Text("Modo Administrador", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded, color: Colors.orange),
            tooltip: "Dashboard Financiero",
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: "Cerrar Sesión",
            onPressed: () {
              authProvider.logout();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // KPI Header
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Ocupación:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                  Text("$totalOcupados / $totalEspacios", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                ],
              ),
            ),

            // Mapa de Zonas
            Expanded(
              child: _buildLayoutZonas(context, espacios),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutZonas(BuildContext context, List<dynamic> espacios) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final double gap = 10.0;

        final hZonaA = (h * 0.28) - gap; // Un poco más alta para que quepa la lista vertical
        final wZonaB = (w * 0.28) - gap;
        final wZonaCD = w - wZonaB - gap;
        final hRestante = h - hZonaA - gap;
        final hZonaC = (hRestante / 2) - (gap / 2);
        final hZonaD = (hRestante / 2) - (gap / 2);

        return Stack(
          children: [
            // Zona A
            Positioned(top: 0, left: 0, right: 0, height: hZonaA,
                child: _buildZonaCard(context, "A", const Color(0xFF10B981), espacios, isVertical: false)),
            // Zona C
            Positioned(top: hZonaA + gap, left: 0, width: wZonaCD, height: hZonaC,
                child: _buildZonaCard(context, "C", const Color(0xFF8B5CF6), espacios, isVertical: false)),
            // Zona D
            Positioned(top: hZonaA + gap + hZonaC + gap, left: 0, width: wZonaCD, height: hZonaD,
                child: _buildZonaCard(context, "D", const Color(0xFFF59E0B), espacios, isVertical: false)),
            // Zona B (Vertical)
            Positioned(top: hZonaA + gap, right: 0, width: wZonaB, height: hRestante,
                child: _buildZonaCard(context, "B", const Color(0xFF0EA5E9), espacios, isVertical: true)),

            // Etiqueta Entrada
            Positioned(
              top: hZonaA + (gap / 2) - 8,
              left: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text("ENTRADA ", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                    Icon(Icons.arrow_forward, color: Colors.red, size: 14),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildZonaCard(BuildContext context, String letra, Color colorBase, List<dynamic> espacios, {bool isVertical = false}) {
    int libres = _contar(letra, "LIBRE", espacios);
    int ocupados = _contar(letra, "OCUPADO", espacios);
    int reservados = _contar(letra, "RESERVADO", espacios);
    int mantenimiento = _contar(letra, "MANTENIMIENTO", espacios);

    int total = libres + ocupados + reservados + mantenimiento;
    double porcentajeLibres = total > 0 ? (libres / total) : 0;

    // Si quieres barras de progreso visuales, puedes calcular el porcentaje aquí
    // double porcentaje = (libres + ocupados + reservados + mant) > 0 ? ocupados / (libres + ocupados + reservados + mant) : 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminSectionDetailScreen(sectionId: letra)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorBase.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(color: colorBase.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.all(8),

        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: SizedBox(
            width: isVertical ? 100 : 220,
            height: isVertical ? 250 : 100,

            child: isVertical
                ? _buildContenidoVertical(letra, colorBase, libres, ocupados, reservados, mantenimiento, porcentajeLibres)
                : _buildContenidoHorizontal(letra, colorBase, libres, ocupados, reservados, mantenimiento, porcentajeLibres, total),
          ),
        ),
      ),
    );
  }

  // CONTENIDO VERTICAL (ZONA B)
  // --- ZONA VERTICAL (B) ---
  Widget _buildContenidoVertical(String letra, Color color, int l, int o, int r, int m, double p) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
          child: Text(letra, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 24)),
        ),
        CircularProgressIndicator(value: p, backgroundColor: Colors.grey.shade200, color: color),
        Text("${(p * 100).toInt()}%", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),

        Column(
          children: [
            _miniBadge(Colors.green, "$l Libres"),
            const SizedBox(height: 2),
            _miniBadge(Colors.orange, "$r Reserv"),
            const SizedBox(height: 2),
            _miniBadge(Colors.red, "$o Ocup"),
            const SizedBox(height: 2),
            _miniBadge(Colors.grey, "$m Mant"),
          ],
        )
      ],
    );
  }

  // --- ZONAS HORIZONTALES (A, C, D) ---
  Widget _buildContenidoHorizontal(String letra, Color color, int l, int o, int r, int m, double p, int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
                  child: Text(letra, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("ZONA $letra", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("$total Espacios", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                SizedBox(
                  width: 60,
                  child: LinearProgressIndicator(value: p, backgroundColor: Colors.grey.shade200, color: color, minHeight: 6),
                ),
                const SizedBox(width: 5),
                Text("${(p * 100).toInt()}%", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
              ],
            )
          ],
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _miniBadge(Colors.green, "$l Libres"),
            const SizedBox(height: 2),
            _miniBadge(Colors.orange, "$r Reserv"),
            const SizedBox(height: 2),
            _miniBadge(Colors.red, "$o Ocup"),
            const SizedBox(height: 2),
            _miniBadge(Colors.grey, "$m Mant"),
          ],
        )
      ],
    );
  }

  Widget _miniBadge(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }
}