import 'package:flutter/material.dart';

class GlowingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double height;
  final Color glowColor;

  const GlowingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 48,
    this.glowColor = const Color(0xFF00E5FF),
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: glowColor.withOpacity(0.18), blurRadius: 18, spreadRadius: 2),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: glowColor,
          foregroundColor: Colors.black,
          minimumSize: Size.fromHeight(height),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 6,
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
