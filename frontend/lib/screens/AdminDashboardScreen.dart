import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/parking_provider.dart';

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

    final double libres = (stats['libres'] ?? 0).toDouble();
    final double ocupados = (stats['ocupados'] ?? 0).toDouble();
    final double reservados = (stats['reservados'] ?? 0).toDouble();
    final double mant = (stats['mantenimiento'] ?? 0).toDouble();
    final int totalReservas = stats['totalReservasHoy'] ?? 0;

    final double totalEspacios = libres + ocupados + reservados + mant;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Reporte Financiero", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B))),
            Text("Estadísticas del día", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Métricas Clave", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 15),

            // --- 1. FILA DE KPIs (Tarjetas) ---
            Row(
              children: [
                const SizedBox(width: 15),
                _buildKpiCard(
                  "Reservas Totales",
                  "$totalReservas",
                  Icons.receipt_long_outlined,
                  Colors.blue,
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Text("Distribución de Ocupación", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 250,
                    child: Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 4, // Espacio entre rebanadas
                            centerSpaceRadius: 70, // Dona más ancha
                            startDegreeOffset: -90,
                            sections: [
                              _buildPieSection(libres, Colors.green, "Libres"),
                              _buildPieSection(ocupados, Colors.red, "Ocup"),
                              _buildPieSection(reservados, Colors.orange, "Resv"),
                              _buildPieSection(mant, Colors.grey, "Mant"),
                            ],
                          ),
                        ),
                        // TEXTO EN EL CENTRO DE LA DONA
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${totalEspacios.toInt()}",
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                              ),
                              const Text(
                                "Total Espacios",
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // LEYENDA MEJORADA
                  Wrap(
                    spacing: 16,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildLegendItem(Colors.green, "Libres", libres),
                      _buildLegendItem(Colors.red, "Ocupados", ocupados),
                      _buildLegendItem(Colors.orange, "Reservados", reservados),
                      _buildLegendItem(Colors.grey, "Mantenimiento", mant),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _buildPieSection(double value, Color color, String title) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: value > 0 ? '${value.toInt()}' : '',
      radius: 25, // Grosor de la dona
      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      badgeWidget: value > 0 ? _Badge(color: color, text: title) : null,
      badgePositionPercentageOffset: 1.4, // Aleja la etiqueta del centro
    );
  }

  Widget _buildLegendItem(Color color, String label, double value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text("$label: ${value.toInt()}", style: const TextStyle(fontSize: 13, color: Color(0xFF475569), fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// Widget interno para las etiquetas flotantes del gráfico
class _Badge extends StatelessWidget {
  final Color color;
  final String text;

  const _Badge({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2)],
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}