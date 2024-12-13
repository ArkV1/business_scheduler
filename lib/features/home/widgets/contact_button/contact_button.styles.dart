// contact_button.styles.dart
import 'package:flutter/material.dart';
import 'package:mix/mix.dart' hide $token;
import 'package:appointment_app/design/tokens/tokens.dart';

class ContactButtonStyles {
  Style container() => Style(
    $box.color.ref($token.color.card),
    $box.borderRadius.all.ref($token.radius.medium),
    $box.padding.vertical(16),
    $box.border.color.ref($token.color.border),
    $box.elevation(0),  // Default no elevation
    
    $on.hover(
      $with.scale(1.02),
      $box.elevation(1),  // Add elevation on hover instead of boxShadow
    ),
    
    $on.press(
      $with.scale(0.98),
    ),
  );

  Style icon() => Style(
    $icon.size(24),
    $icon.color.ref($token.color.onSurface),
  );

  Style label() => Style(
    $text.style.ref($token.textStyle.labelMedium),
    $text.style.color.ref($token.color.onSurface),
  );
}

// contact_button.dart
class ContactButton extends StatelessWidget {
  const ContactButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final styles = ContactButtonStyles();

    return PressableBox(
      onPress: onTap,
      style: styles.container(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StyledIcon(
            icon,
            style: styles.icon(),
          ),
          const SizedBox(height: 4),
          StyledText(
            label,
            style: styles.label(),
          ),
        ],
      ),
    );
  }
}