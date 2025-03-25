import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircularAnimation extends StatefulWidget {
  const CircularAnimation({super.key});

  @override
  _CircularAnimationState createState() => _CircularAnimationState();
}

class _CircularAnimationState extends State<CircularAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(
          Icons.autorenew, // You can replace this with any icon or widget
          size: 48,
          color: Colors.blue,
        ),
      ),
    );
  }
}
