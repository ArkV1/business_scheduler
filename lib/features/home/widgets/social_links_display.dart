import 'package:flutter/material.dart';
import '../models/social_link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../common/widgets/hover_container.dart';

class SocialLinksDisplay extends StatelessWidget {
  final List<SocialLink> socialLinks;
  final bool isPreview;
  final double maxWidth;

  const SocialLinksDisplay({
    super.key,
    required this.socialLinks,
    this.isPreview = false,
    this.maxWidth = 600,
  });

  IconData? _getIconForPlatform(String name) {
    const predefinedPlatforms = {
      'Facebook': Icons.facebook,
      'Instagram': Icons.camera_alt,
      'TikTok': Icons.video_library,
      'WhatsApp': Icons.message,
      'Phone': Icons.phone,
      'Email': Icons.email,
      'Website': Icons.language,
    };
    return predefinedPlatforms[name];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';
    
    final header = socialLinks.firstWhere(
      (link) => link.isHeader && link.id == 'header',
      orElse: () => SocialLink(
        id: 'header',
        name: l10n.contact,
        nameHe: 'צור קשר',
        isHeader: true,
        order: -1,
      ),
    );

    final activeLinks = socialLinks.where((link) => 
      !link.isHeader && (isPreview || link.isActive)
    ).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    if (activeLinks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                isHebrew ? (header.nameHe ?? header.name) : header.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: activeLinks.map((link) => _SocialLinkItem(
              link: link,
              isPreview: isPreview,
              isHebrew: isHebrew,
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _SocialLinkItem extends StatelessWidget {
  final SocialLink link;
  final bool isPreview;
  final bool isHebrew;

  const _SocialLinkItem({
    required this.link,
    required this.isPreview,
    required this.isHebrew,
  });

  IconData? _getIconForPlatform(String name) {
    const predefinedPlatforms = {
      'Facebook': Icons.facebook,
      'Instagram': Icons.camera_alt,
      'TikTok': Icons.video_library,
      'WhatsApp': Icons.message,
      'Phone': Icons.phone,
      'Email': Icons.email,
      'Website': Icons.language,
    };
    return predefinedPlatforms[name];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: HoverContainer(
        scale: 1.05,
        onTap: isPreview ? null : () async {
          if (link.url != null) {
            final uri = Uri.parse(link.url!);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          }
        },
        builder: (context, isHovered) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isHovered
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Theme.of(context).cardColor,
                border: Border.all(
                  color: isHovered
                      ? Theme.of(context).primaryColor.withOpacity(0.2)
                      : Theme.of(context).dividerColor.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isHovered ? Theme.of(context).primaryColor : Theme.of(context).dividerColor).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: link.iconPath != null && link.iconPath!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      link.iconPath!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        final iconData = _getIconForPlatform(link.name);
                        return Icon(
                          iconData ?? Icons.link,
                          size: 20,
                          color: isHovered ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                        );
                      },
                    ),
                  )
                : Icon(
                    _getIconForPlatform(link.name) ?? Icons.link,
                    size: 20,
                    color: isHovered ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isHebrew ? (link.nameHe ?? link.name) : link.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isHovered 
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isHovered ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}