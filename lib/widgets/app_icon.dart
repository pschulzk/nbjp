import 'package:flutter/material.dart';

class AppIconWidget extends StatelessWidget {
  final double size;
  final bool showBackground;
  
  const AppIconWidget({
    super.key,
    this.size = 120,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: showBackground ? BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF001A1A), // Very dark teal
            Colors.black,
            const Color(0xFF000D1A), // Very dark blue
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ) : null,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // "NB" with gradient
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF00D4FF), // Cyan
                  Color(0xFF0099FF), // Blue
                ],
              ).createShader(bounds),
              child: Text(
                'NB',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.36,
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -size * 0.01,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ),
            // "JP" with different gradient
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFF00F5), // Magenta
                  Color(0xFF7000FF), // Purple
                ],
              ).createShader(bounds),
              child: Text(
                'JP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.36,
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -size * 0.01,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}