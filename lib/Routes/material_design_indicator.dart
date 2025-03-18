import 'package:flutter/material.dart';

class MaterialDesignIndicator extends Decoration {
  final double indicatorHeight;
  final Color? indicatorColor; // Make indicatorColor optional

  const MaterialDesignIndicator({
    required this.indicatorHeight,
    this.indicatorColor, // Update constructor
  });

  @override
  _MaterialDesignPainter createBoxPainter([VoidCallback? onChanged]) {
    return _MaterialDesignPainter(this, onChanged);
  }
}

class _MaterialDesignPainter extends BoxPainter {
  final MaterialDesignIndicator decoration;

  _MaterialDesignPainter(this.decoration, VoidCallback? onChanged)
      : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);

    final Rect rect = Offset(
          offset.dx,
          configuration.size!.height - decoration.indicatorHeight,
        ) &
        Size(configuration.size!.width, decoration.indicatorHeight);

    final Paint paint = Paint()
      ..color = decoration.indicatorColor ?? Colors.blue // Default color if null
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        topRight: Radius.circular(8),
        topLeft: Radius.circular(8),
      ),
      paint,
    );
  }
}