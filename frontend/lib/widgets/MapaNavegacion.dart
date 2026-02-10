import 'package:flutter/material.dart';

class MapaNavegacion extends StatelessWidget {
  final String zonaDestino;

  const MapaNavegacion({super.key, required this.zonaDestino});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black45, width: 2),
      ),
      child: Stack(
        children: [
          CustomPaint(
            painter: _ParkingPainter(),
            size: Size.infinite,
          ),
          CustomPaint(
            painter: _RutaPainter(zona: zonaDestino),
            size: Size.infinite,
          ),
          Positioned(
            bottom: 190,
            left: -1,
            child: RotatedBox(
              quarterTurns: 3,
              child: const Text("ENTRADA",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: Colors.red)
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ParkingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.shade300..style = PaintingStyle.fill;
    final border = Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 1.5;

    final w = size.width;
    final h = size.height;

    final rectA = Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.9, h * 0.20);
    final rectB = Rect.fromLTWH(w * 0.75, h * 0.30, w * 0.20, h * 0.65);
    final rectC = Rect.fromLTWH(w * 0.05, h * 0.30, w * 0.60, h * 0.30);
    final rectD = Rect.fromLTWH(w * 0.05, h * 0.65, w * 0.60, h * 0.30);

    canvas.drawRect(rectA, paint); canvas.drawRect(rectA, border);
    canvas.drawRect(rectB, paint); canvas.drawRect(rectB, border);
    canvas.drawRect(rectC, paint); canvas.drawRect(rectC, border);
    canvas.drawRect(rectD, paint); canvas.drawRect(rectD, border);

    _drawText(canvas, "A", rectA.center);
    _drawText(canvas, "B", rectB.center);
    _drawText(canvas, "C", rectC.center);
    _drawText(canvas, "D", rectD.center);
  }

  void _drawText(Canvas canvas, String text, Offset center) {
    final textSpan = TextSpan(
        text: text,
        style: const TextStyle(color: Colors.black38, fontSize: 24, fontWeight: FontWeight.bold)
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width/2, center.dy - textPainter.height/2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RutaPainter extends CustomPainter {
  final String zona;
  _RutaPainter({required this.zona});

  @override
  void paint(Canvas canvas, Size size) {
    final paintRuta = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final paintPuntoInicio = Paint()..color = Colors.red..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final startX = w * 0.02;
    final startY = h * 0.27;

    canvas.drawCircle(Offset(startX + 5, startY), 8, paintPuntoInicio);

    final path = Path();
    path.moveTo(startX + 5, startY);

    if (zona.startsWith("A")) {
      path.lineTo(w * 0.70, startY);
      path.lineTo(w * 0.70, h * 0.28);
      path.lineTo(w * 0.5, h * 0.28);
      _drawArrow(path, w * 0.5, h * 0.25, "UP");

    } else if (zona.startsWith("B")) {
      path.lineTo(w * 0.70, startY);
      path.lineTo(w * 0.70, h * 0.6);
      path.lineTo(w * 0.73, h * 0.6);
      _drawArrow(path, w * 0.75, h * 0.6, "RIGHT");

    } else if (zona.startsWith("C")) {
      path.lineTo(w * 0.70, startY);
      path.lineTo(w * 0.70, h * 0.45);
      path.lineTo(w * 0.63, h * 0.45);
      _drawArrow(path, w * 0.60, h * 0.45, "LEFT");

    } else if (zona.startsWith("D")) {
      path.lineTo(w * 0.70, startY);
      path.lineTo(w * 0.70, h * 0.8);
      path.lineTo(w * 0.63, h * 0.8);
      _drawArrow(path, w * 0.60, h * 0.8, "LEFT");
    }

    canvas.drawPath(path, paintRuta);
  }

  void _drawArrow(Path path, double x, double y, String direction) {
    const double size = 10;
    path.moveTo(x, y);

    if (direction == "UP") {
      path.lineTo(x - size, y + size);
      path.moveTo(x, y);
      path.lineTo(x + size, y + size);
    } else if (direction == "DOWN") {
      path.lineTo(x - size, y - size);
      path.moveTo(x, y);
      path.lineTo(x + size, y - size);
    } else if (direction == "LEFT") {
      path.lineTo(x + size, y - size);
      path.moveTo(x, y);
      path.lineTo(x + size, y + size);
    } else if (direction == "RIGHT") {
      path.lineTo(x - size, y - size);
      path.moveTo(x, y);
      path.lineTo(x - size, y + size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}