import 'package:flutter/material.dart';

class FunDecorations extends StatelessWidget {
  const FunDecorations({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 100,
          left: 30,
          child: FloatingEmoji('⭐', 20),
        ),
        Positioned(
          top: 150,
          right: 50,
          child: FloatingEmoji('🌈', 24),
        ),
        Positioned(
          top: 200,
          left: 60,
          child: FloatingEmoji('✨', 18),
        ),
        Positioned(
          top: 300,
          right: 30,
          child: FloatingEmoji('🦋', 22),
        ),
        Positioned(
          bottom: 200,
          left: 40,
          child: FloatingEmoji('🌸', 20),
        ),
        Positioned(
          bottom: 250,
          right: 60,
          child: FloatingEmoji('💫', 19),
        ),
      ],
    );
  }
}

class FloatingEmoji extends StatelessWidget {
  final String emoji;
  final double size;

  const FloatingEmoji(this.emoji, this.size, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      emoji,
      style: TextStyle(
        fontSize: size,
        shadows: [
          Shadow(
            color: Colors.white,
            blurRadius: 5,
          ),
          Shadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }
}