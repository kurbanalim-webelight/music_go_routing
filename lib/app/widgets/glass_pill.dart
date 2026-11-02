import 'dart:ui';

import 'package:material_ui/material_ui.dart';

// Frosted, fully rounded surface shared by the floating mini player and bottom bar.
class GlassPill extends StatelessWidget {
  const GlassPill({required this.child, this.radius = 40, super.key});

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xD9221C29),
              borderRadius: shape,
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
