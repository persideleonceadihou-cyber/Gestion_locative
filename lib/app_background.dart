import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  static const cream = Color(0xFFFFF7D9);
  static const creamDeep = Color(0xFFFFECA8);
  static const white = Color(0xFFFFFCF4);
  static const blue = Color(0xFF1D6FEA);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final isWide = width >= 720;
        final blueSize = isWide ? width * 0.22 : width * 0.42;
        final whiteSize = isWide ? width * 0.36 : width * 0.72;

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cream, cream, creamDeep, white],
              stops: [0, 0.58, 0.72, 1],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -whiteSize * 0.22,
                right: -whiteSize * 0.18,
                child: _SoftCircle(
                  size: whiteSize,
                  color: Colors.white.withOpacity(0.72),
                ),
              ),
              Positioned(
                left: -whiteSize * 0.3,
                bottom: height * 0.08,
                child: _SoftCircle(
                  size: whiteSize * 0.82,
                  color: Colors.white.withOpacity(0.48),
                ),
              ),
              Positioned(
                top: isWide ? height * 0.14 : height * 0.1,
                left: isWide ? width * 0.1 : -blueSize * 0.18,
                child: _SoftCircle(
                  size: blueSize,
                  color: blue.withOpacity(0.1),
                ),
              ),
              Positioned(
                right: -blueSize * 0.28,
                bottom: -blueSize * 0.16,
                child: _SoftCircle(
                  size: blueSize * 1.12,
                  color: blue.withOpacity(0.08),
                ),
              ),
              child,
            ],
          ),
        );
      },
    );
  }
}

class _SoftCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
