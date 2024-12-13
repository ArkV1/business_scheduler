import 'package:flutter/material.dart';
import '../models/social_link.dart';
import 'social_links_display.dart';

class SocialLinks extends StatelessWidget {
  final List<SocialLink> socialLinks;

  const SocialLinks({
    super.key,
    required this.socialLinks,
  });

  @override
  Widget build(BuildContext context) {
    return SocialLinksDisplay(socialLinks: socialLinks);
  }
} 