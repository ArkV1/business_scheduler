import 'package:flutter/material.dart';

class HoverContainer extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovered) builder;
  final Duration duration;
  final Curve curve;
  final void Function()? onTap;
  final double scale;

  const HoverContainer({
    super.key,
    required this.builder,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.onTap,
    this.scale = 1.1,
  });

  @override
  State<HoverContainer> createState() => _HoverContainerState();
}

class _HoverContainerState extends State<HoverContainer> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: isHovered ? widget.scale : 1.0,
          duration: widget.duration,
          curve: widget.curve,
          child: widget.builder(context, isHovered),
        ),
      ),
    );
  }
} 