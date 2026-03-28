import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'game_models.dart';

class ShapeSelector extends StatelessWidget {
  final ShapeType current;
  final ValueChanged<ShapeType> onSelect;
  final AnimationController morphCtrl;

  const ShapeSelector({
    super.key,
    required this.current,
    required this.onSelect,
    required this.morphCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.bgCard.withOpacity(0.9),
        border: Border.all(color: AppTheme.wallBorder, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ShapeConfig.all.map((config) => _ShapeBtn(
          config: config,
          isSelected: current == config.type,
          onTap: () => onSelect(config.type),
          morphCtrl: morphCtrl,
        )).toList(),
      ),
    );
  }
}

class _ShapeBtn extends StatefulWidget {
  final ShapeConfig config;
  final bool isSelected;
  final VoidCallback onTap;
  final AnimationController morphCtrl;

  const _ShapeBtn({
    required this.config,
    required this.isSelected,
    required this.onTap,
    required this.morphCtrl,
  });

  @override
  State<_ShapeBtn> createState() => _ShapeBtnState();
}

class _ShapeBtnState extends State<_ShapeBtn> with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.config.color;
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) { _pressCtrl.reverse(); widget.onTap(); },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (_, child) => Transform.scale(
          scale: 1.0 - _pressCtrl.value * 0.08,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: widget.isSelected ? 96 : 84,
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: widget.isSelected
                ? LinearGradient(
              colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
                : null,
            color: widget.isSelected ? null : AppTheme.bgSurface,
            border: Border.all(
              color: widget.isSelected ? color : AppTheme.wallBorder,
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected
                ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 16, spreadRadius: 2)]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CustomPaint(painter: _ShapeIconPainter(color, widget.config.type)),
              ),
              const SizedBox(height: 4),
              Text(
                widget.config.label,
                style: GoogleFonts.rajdhani(
                  fontSize: 9,
                  color: widget.isSelected ? color : AppTheme.textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShapeIconPainter extends CustomPainter {
  final Color color;
  final ShapeType shape;
  _ShapeIconPainter(this.color, this.shape);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final glow = Paint()
      ..color = color.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final cx = size.width / 2;
    final cy = size.height / 2;
    switch (shape) {
      case ShapeType.circle:
        canvas.drawCircle(Offset(cx, cy), cx * 0.7, glow);
        canvas.drawCircle(Offset(cx, cy), cx * 0.7, paint);
        break;
      case ShapeType.square:
        final r = cx * 0.7;
        canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2), glow);
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2), const Radius.circular(3)),
          paint,
        );
        break;
      case ShapeType.triangle:
        final h = cx * 0.7;
        final path = Path()
          ..moveTo(cx, cy - h)
          ..lineTo(cx + h, cy + h)
          ..lineTo(cx - h, cy + h)
          ..close();
        canvas.drawPath(path, glow);
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}