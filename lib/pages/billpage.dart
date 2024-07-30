import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class BillPage extends StatelessWidget {
  final List<Map<String, dynamic>> numberData;
  final int total;
  final DateTime timestamp;

  const BillPage({
    super.key,
    required this.numberData,
    required this.total,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    var formatter = NumberFormat('#,###');

    return Scaffold(
      appBar: AppBar(
        title: const Text('ບິນການຊື້'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: WatermarkPainter(
                text: DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                Text(
                  'ວັນທີ-ເວລາ: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp)}',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: numberData.length,
                    itemBuilder: (context, index) {
                      final data = numberData[index];
                      return ListTile(
                        dense: true,
                        visualDensity:
                            const VisualDensity(vertical: -4), // to compact
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        title: Text('ເລກ: ${data['number']}'),
                        trailing: Text(formatter.format(data['price'])),
                      );
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text(
                    'ລວມທັງໝົດ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    formatter.format(total),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WatermarkPainter extends CustomPainter {
  final String text;

  WatermarkPainter({required this.text});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final textStyle = TextStyle(
      color: Colors.grey.shade300,
      fontSize: 12,
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: ui.TextDirection.ltr,
    );

    textPainter.layout();

    // Spacing between watermarks
    const double dx = 100.0;
    const double dy = 50.0;

    // Draw the watermark in a grid pattern
    for (double y = 0; y < size.height; y += dy) {
      for (double x = 0; x < size.width; x += dx) {
        textPainter.paint(canvas, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
