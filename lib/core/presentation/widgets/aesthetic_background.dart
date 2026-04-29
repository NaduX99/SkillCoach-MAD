import 'package:flutter/material.dart';

class AestheticBackground extends StatelessWidget {
  final Widget child;
  const AestheticBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Premium Gradient Background (Static, const for zero rebuilds)
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF8FAFC),
                  Color(0xFFF1F5F9),
                  Color(0xFFE2E8F0),
                ],
              ),
            ),
          ),
        ),

        // 2. Decorative circles — PERFORMANCE FIX: removed expensive boxShadow
        // with large blurRadius/spreadRadius. Using simple colored circles with
        // Opacity instead, which are GPU-composited and don't cause jank.
        Positioned(
          top: 100,
          right: -50,
          child: RepaintBoundary(
            child: Opacity(
              opacity: 0.08,
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 200,
          left: -100,
          child: RepaintBoundary(
            child: Opacity(
              opacity: 0.04,
              child: Container(
                width: 400,
                height: 400,
                decoration: const BoxDecoration(
                  color: Color(0xFF818CF8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),

        // 3. Content
        child,
      ],
    );
  }
}
