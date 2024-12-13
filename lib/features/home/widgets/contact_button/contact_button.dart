// contact_button.dart
import 'package:flutter/material.dart';
import 'package:mix/mix.dart' hide $token;
import 'package:appointment_app/features/home/widgets/contact_button/contact_button.styles.dart';

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