import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Border? border;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.1,
    this.borderRadius,
    this.padding,
    this.margin,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: border ??
            Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: opacity),
                  Colors.white.withValues(alpha: opacity * 0.5),
                ],
              ),
            ),
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
