import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraControlButton extends StatefulWidget {
  final String icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool isDisabled;

  const CameraControlButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.isDisabled = false,
    super.key,
  });

  @override
  State<CameraControlButton> createState() => _CameraControlButtonState();
}

class _CameraControlButtonState extends State<CameraControlButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
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
    if (widget.isDisabled) return;

    HapticFeedback.lightImpact();

    await _animationController.forward();
    widget.onTap();
    await _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isDisabled
                      ? Colors.grey.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.icon,
                    style: TextStyle(
                      fontSize: 28,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CameraControls extends StatelessWidget {
  final String flashIcon;
  final String cameraIcon;
  final VoidCallback onFlashTap;
  final VoidCallback onCameraTap;
  final bool isDisabled;
  final bool hasMultipleCameras;

  const CameraControls({
    required this.flashIcon,
    required this.cameraIcon,
    required this.onFlashTap,
    required this.onCameraTap,
    this.isDisabled = false,
    this.hasMultipleCameras = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      right: 20,
      child: Column(
        children: [
          CameraControlButton(
            icon: flashIcon,
            onTap: onFlashTap,
            tooltip: 'Toggle Flash',
            isDisabled: isDisabled,
          ),
          const SizedBox(height: 16),
          if (hasMultipleCameras)
            CameraControlButton(
              icon: cameraIcon,
              onTap: onCameraTap,
              tooltip: 'Switch Camera',
              isDisabled: isDisabled,
            ),
        ],
      ),
    );
  }
}