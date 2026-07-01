import 'package:flutter/material.dart';

class PatternLockWidget extends StatefulWidget {
  final Function(List<int> pattern) onComplete;
  final Color activeColor;
  final Color dotColor;

  const PatternLockWidget({
    Key? key,
    required this.onComplete,
    this.activeColor = Colors.indigo,
    this.dotColor = Colors.grey,
  }) : super(key: key);

  @override
  State<PatternLockWidget> createState() => _PatternLockWidgetState();
}

class _PatternLockWidgetState extends State<PatternLockWidget> {
  static const int gridSize = 3;
  List<Offset> dotPositions = [];
  List<int> selectedDots = [];
  Offset? currentPoint;
  final double dotRadius = 12;
  final double hitRadius = 30;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        _calculateDotPositions(size);
        return GestureDetector(
          onPanStart: (details) => _handleTouch(details.localPosition),
          onPanUpdate: (details) => _handleTouch(details.localPosition),
          onPanEnd: (_) => _handlePanEnd(),
          child: CustomPaint(
            size: Size(size, size),
            painter: _PatternPainter(
              dotPositions: dotPositions,
              selectedDots: selectedDots,
              currentPoint: currentPoint,
              activeColor: widget.activeColor,
              dotColor: widget.dotColor,
              dotRadius: dotRadius,
            ),
          ),
        );
      },
    );
  }

  void _calculateDotPositions(double size) {
    if (dotPositions.isNotEmpty) return;
    final spacing = size / (gridSize + 1);
    dotPositions = [];
    for (int row = 1; row <= gridSize; row++) {
      for (int col = 1; col <= gridSize; col++) {
        dotPositions.add(Offset(spacing * col, spacing * row));
      }
    }
  }

  void _handleTouch(Offset point) {
    setState(() {
      currentPoint = point;
      for (int i = 0; i < dotPositions.length; i++) {
        if (!selectedDots.contains(i)) {
          final distance = (dotPositions[i] - point).distance;
          if (distance < hitRadius) {
            selectedDots.add(i);
          }
        }
      }
    });
  }

  void _handlePanEnd() {
    if (selectedDots.isNotEmpty) {
      widget.onComplete(List.from(selectedDots));
    }
    setState(() {
      selectedDots = [];
      currentPoint = null;
    });
  }
}

class _PatternPainter extends CustomPainter {
  final List<Offset> dotPositions;
  final List<int> selectedDots;
  final Offset? currentPoint;
  final Color activeColor;
  final Color dotColor;
  final double dotRadius;

  _PatternPainter({
    required this.dotPositions,
    required this.selectedDots,
    required this.currentPoint,
    required this.activeColor,
    required this.dotColor,
    required this.dotRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = activeColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < selectedDots.length - 1; i++) {
      canvas.drawLine(dotPositions[selectedDots[i]], dotPositions[selectedDots[i + 1]], linePaint);
    }
    if (selectedDots.isNotEmpty && currentPoint != null) {
      canvas.drawLine(dotPositions[selectedDots.last], currentPoint!, linePaint);
    }

    for (int i = 0; i < dotPositions.length; i++) {
      final isSelected = selectedDots.contains(i);

      if (isSelected) {
        final glowPaint = Paint()
          ..color = activeColor.withOpacity(0.15)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(dotPositions[i], dotRadius + 10, glowPaint);
      }

      final innerPaint = Paint()
        ..color = isSelected ? activeColor : dotColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(dotPositions[i], dotRadius, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) => true;
}
