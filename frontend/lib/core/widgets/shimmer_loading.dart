import 'package:flutter/material.dart';

/// Grey animated gradient placeholder (shimmer).
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF2A3038) : const Color(0xFFE2E8F0);
    final highlight = isDark ? const Color(0xFF3D4654) : const Color(0xFFF1F5F9);

    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(-1.0 + t * 2, 0),
              end: Alignment(0.2 + t * 2, 0),
              colors: [
                base,
                highlight,
                base,
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        );
      },
    );
  }
}
