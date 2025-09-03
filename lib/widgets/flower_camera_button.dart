import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class FlowerCameraButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const FlowerCameraButton({
    required this.onTap, 
    this.isLoading = false,
    super.key,
  });

  @override
  State<FlowerCameraButton> createState() => _FlowerCameraButtonState();
}

class _FlowerCameraButtonState extends State<FlowerCameraButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (widget.isLoading) return;
    
    setState(() => _isPressed = true);
    
    // Play haptic feedback
    HapticFeedback.mediumImpact();
    
    // Play animation
    await _animationController.forward();
    
    // Trigger the actual camera capture
    widget.onTap();
    
    // Reset animation
    await _animationController.reverse();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Center(
        child: ElevatedButton(
          onPressed: _handleTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.zero,
            shape: const CircleBorder(),
            elevation: 0,
          ),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withValues(alpha: _isPressed ? 0.6 : 0.4),
                        blurRadius: _isPressed ? 20 : 15,
                        offset: Offset(0, _isPressed ? 3 : 5),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: FlowerButtonPainter(
                      isPressed: _isPressed,
                      isLoading: widget.isLoading,
                    ),
                    child: Center(
                      child: widget.isLoading
                          ? const SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: _isPressed ? 32 : 36,
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class FlowerButtonPainter extends CustomPainter {
  final bool isPressed;
  final bool isLoading;
  
  FlowerButtonPainter({
    this.isPressed = false, 
    this.isLoading = false,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Create flower petals
    final petalPaint = Paint()
      ..style = PaintingStyle.fill;
    
    // Draw 6 colorful petals around the center
    final petalColors = [
      const Color(0xFFFF69B4), // Hot pink
      const Color(0xFFFFB6C1), // Light pink
      const Color(0xFFFF1493), // Deep pink
      const Color(0xFFFFC0CB), // Pink
      const Color(0xFFFF69B4), // Hot pink
      const Color(0xFFFFB6C1), // Light pink
    ];
    
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * (3.14159 / 180); // Convert to radians
      petalPaint.color = petalColors[i];
      
      // Create petal shape (ellipse)
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      
      final petalRect = Rect.fromCenter(
        center: Offset(0, -radius * 0.4),
        width: radius * 0.8,
        height: radius * 0.6,
      );
      
      canvas.drawOval(petalRect, petalPaint);
      canvas.restore();
    }
    
    // Draw center circle (button area) - different color when loading/pressed
    Color centerColor;
    if (isLoading) {
      centerColor = const Color(0xFFFFB347); // Orange when loading
    } else if (isPressed) {
      centerColor = const Color(0xFF228B22); // Dark green when pressed
    } else {
      centerColor = const Color(0xFF32CD32); // Lime green normally
    }
    final centerPaint = Paint()
      ..color = centerColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius * 0.4, centerPaint);
    
    // Add gradient effect to center
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF98FB98).withValues(alpha: 0.8), // Pale green
          centerColor, // Dynamic green based on pressed state
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.4));
    
    canvas.drawCircle(center, radius * 0.4, gradientPaint);
    
    // Add sparkle effect
    final sparklePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    
    // Draw small sparkles around the flower
    for (int i = 0; i < 8; i++) {
      final sparkleAngle = (i * 45) * (3.14159 / 180);
      final sparkleDistance = radius * 0.9;
      final sparkleX = center.dx + sparkleDistance * math.cos(sparkleAngle);
      final sparkleY = center.dy + sparkleDistance * math.sin(sparkleAngle);
      
      canvas.drawCircle(Offset(sparkleX, sparkleY), 2, sparklePaint);
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}