import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/parking_provider.dart';
import '../providers/auth_provider.dart';
import './SectionDetailScreen.dart';
import 'dart:async';
import './reservations_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final parkingProvider = Provider.of<ParkingProvider>(context, listen: false);
      parkingProvider.cargarEspacios(checkBackground: false);

      _timer = Timer.periodic(const Duration(seconds: 3), (_) {
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
    return espacios.where((e) =>
    e.identificador.startsWith(letra) && e.estado == estado
    ).length;
  }

  @override
  Widget build(BuildContext context) {
    final parkingProvider = Provider.of<ParkingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final espacios = parkingProvider.espacios;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Parqueadero Inteligente",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.calendar_today,
                  color: const Color(0xFF3B82F6),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyReservationsScreen()),
                  );
                },
              ),
            ],
          ),

          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: const Color(0xFFE0F2FE),
              child: Icon(
                Icons.person,
                color: const Color(0xFF0EA5E9),
              ),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                authProvider.logout();
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Estado del parqueadero",
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${espacios.length} espacios totales",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "En línea",
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _buildLeyendaEstados(),

            const SizedBox(height: 16),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Mapa de Zonas",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _buildLayoutZonas(context, espacios),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeyendaEstados() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItemLeyenda(Colors.green, "Libre"),
          _buildItemLeyenda(Colors.orange, "Reservado"),
          _buildItemLeyenda(Colors.red, "Ocupado", ),
          _buildItemLeyenda(Colors.grey, "Mantenimiento"),
        ],
      ),
    );
  }

  Widget _buildItemLeyenda(Color color, String estado) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          estado,
          style: TextStyle(
            fontSize: 11,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLayoutZonas(BuildContext context, List<dynamic> espacios) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        final double gap = 8.0;
        final hZonaA = (h * 0.25) - gap;
        final wZonaB = (w * 0.30) - gap;
        final wZonaCD = w - wZonaB - gap;
        final hRestante = h - hZonaA - gap;
        final hZonaC = (hRestante / 2) - (gap / 2);
        final hZonaD = (hRestante / 2) - (gap / 2);

        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: hZonaA,
              child: _buildZonaCard(context, "A", const Color(0xFF10B981), espacios, isVertical: false),
            ),

            Positioned(
              top: hZonaA + gap,
              left: 0,
              width: wZonaCD,
              height: hZonaC,
              child: _buildZonaCard(context, "C", const Color(0xFF8B5CF6), espacios, isVertical: false),
            ),

            Positioned(
              top: hZonaA + gap + hZonaC + gap,
              left: 0,
              width: wZonaCD,
              height: hZonaD,
              child: _buildZonaCard(context, "D", const Color(0xFFF59E0B), espacios, isVertical: false),
            ),

            Positioned(
              top: hZonaA + gap,
              right: 0,
              width: wZonaB,
              height: hRestante,
              child: _buildZonaCard(context, "B", const Color(0xFF0EA5E9), espacios, isVertical: true),
            ),

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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SectionDetailScreen(sectionId: letra)),
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

  Widget _buildCounterRow(Color color, int count, String label) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "$count",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterVertical(Color color, int count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            "$count",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}