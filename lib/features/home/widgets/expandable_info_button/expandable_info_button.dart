import 'package:flutter/material.dart';
import 'package:mix/mix.dart' hide $token;
import 'package:business_scheduler/design/tokens/tokens.dart';
import 'package:business_scheduler/features/common/widgets/hover_container.dart';

class ExpandableInfoButton extends StatefulWidget {
  final String title;
  final Widget expandedContent;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ExpandableInfoButton({
    super.key,
    required this.title,
    required this.expandedContent,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<ExpandableInfoButton> createState() => _ExpandableInfoButtonState();
}

class _ExpandableInfoButtonState extends State<ExpandableInfoButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(ExpandableInfoButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return HoverContainer(
      onTap: widget.onTap,
      scale: 1.02,
      builder: (context, isHovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isSelected ? [
              theme.primaryColor.withOpacity(isDarkMode ? 0.3 : 0.15),
              theme.primaryColor.withOpacity(isDarkMode ? 0.2 : 0.1),
            ] : [
              theme.cardColor,
              theme.cardColor,
            ],
          ),
          border: Border.all(
            color: widget.isSelected 
                ? theme.primaryColor.withOpacity(isDarkMode ? 0.5 : 0.3)
                : isHovered 
                    ? theme.primaryColor.withOpacity(0.3)
                    : theme.dividerColor.withOpacity(0.2),
            width: (widget.isSelected || isHovered) ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (widget.isSelected ? theme.primaryColor : theme.dividerColor)
                  .withOpacity(isHovered ? 0.15 : 0.1),
              blurRadius: isHovered ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
           
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(isHovered ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.isSelected
                        ? theme.primaryColor.withOpacity(0.2)
                        : theme.dividerColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: theme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
          
            Expanded(
              child: Text(
                widget.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.isSelected 
                      ? theme.primaryColor
                      : theme.textTheme.titleMedium?.color,
                ),
              ),
            ),
            RotationTransition(
              turns: _rotationAnimation,
              child: Icon(
                Icons.expand_more,
                color: widget.isSelected ? theme.primaryColor : theme.iconTheme.color,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 