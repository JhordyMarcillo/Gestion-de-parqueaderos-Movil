import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/parking_provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ParkingProvider>(context, listen: false).cargarEstadisticas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ParkingProvider>(context);
    final stats = provider.stats;

    // Preparar datos para el gráfico (parsear a double por seguridad)
    final double libres = (stats['libres'] ?? 0).toDouble();
    final double ocupados = (stats['ocupados'] ?? 0).toDouble();
    final double reservados = (stats['reservados'] ?? 0).toDouble();
    final double mant = (stats['mantenimiento'] ?? 0).toDouble();

    final total = libres + ocupados + reservados + mant;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Financiero"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Resumen del Día", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // --- 1. TARJETAS DE KPI (Dinero y Flujo) ---
            Row(
              children: [
                const SizedBox(width: 15),
                _buildKpiCard(
                    "Reservas Hoy",
                    "${stats['totalReservasHoy'] ?? 0}",
                    Icons.receipt_long,
                    Colors.blue
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Text("Ocupación en Tiempo Real", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // --- 2. GRÁFICO DE DONA (PIE CHART) ---
            SizedBox(
              height: 250,
              child: total == 0
                  ? const Center(child: Text("Cargando datos..."))
                  : PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50, // Hace que sea una Dona
                  sections: [
                    _buildPieSection(libres, Colors.green, "Libres"),
                    _buildPieSection(ocupados, Colors.red, "Ocup"),
                    _buildPieSection(reservados, Colors.orange, "Reserva"),
                    _buildPieSection(mant, Colors.grey, "Mant"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegend(Colors.green, "Libres ($libres)"),
                _buildLegend(Colors.red, "Ocupados ($ocupados)"),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegend(Colors.orange, "Reservados ($reservados)"),
                _buildLegend(Colors.grey, "Mantenimiento ($mant)"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget para las Tarjetas de arriba (KPIs)
  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
            ],
            border: Border.all(color: color.withOpacity(0.1))
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // Constructor de secciones del Pastel
  PieChartSectionData _buildPieSection(double value, Color color, String title) {
    final isTouched = false; // Podrías hacerlo interactivo luego
    final fontSize = isTouched ? 16.0 : 12.0;
    final radius = isTouched ? 60.0 : 50.0;

    return PieChartSectionData(
      color: color,
      value: value,
      title: value > 0 ? '${value.toInt()}' : '', // Solo muestra número si es mayor a 0
      radius: radius,
      titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  // Widget pequeño para la leyenda de colores
  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
      ],
    );
  }
}