// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class CropBoxPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withOpacity(0.3)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1;
//
//     // Vẽ lưới 3x3
//     final third = size.width / 3;
//     canvas.drawLine(Offset(third, 0), Offset(third, size.height), paint);
//     canvas.drawLine(
//         Offset(2 * third, 0), Offset(2 * third, size.height), paint);
//     canvas.drawLine(Offset(0, third), Offset(size.width, third), paint);
//     canvas.drawLine(Offset(0, 2 * third), Offset(size.width, 2 * third), paint);
//
//     // Vẽ các góc
//     final cornerPaint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3;
//
//     final cornerLength = 20.0;
//
//     // Góc trên trái
//     canvas.drawLine(Offset(0, 0), Offset(cornerLength, 0), cornerPaint);
//     canvas.drawLine(Offset(0, 0), Offset(0, cornerLength), cornerPaint);
//
//     // Góc trên phải
//     canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0),
//         cornerPaint);
//     canvas.drawLine(
//         Offset(size.width, 0), Offset(size.width, cornerLength), cornerPaint);
//
//     // Góc dưới trái
//     canvas.drawLine(
//         Offset(0, size.height), Offset(cornerLength, size.height), cornerPaint);
//     canvas.drawLine(
//         Offset(0, size.height), Offset(0, size.height - cornerLength),
//         cornerPaint);
//
//     // Góc dưới phải
//     canvas.drawLine(Offset(size.width, size.height),
//         Offset(size.width - cornerLength, size.height), cornerPaint);
//     canvas.drawLine(Offset(size.width, size.height),
//         Offset(size.width, size.height - cornerLength), cornerPaint);
//   }
// }