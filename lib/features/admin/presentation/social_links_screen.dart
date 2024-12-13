import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../home/models/social_link.dart';
import '../../home/providers/social_links_provider.dart';
import '../../home/widgets/social_links_display.dart';
import '../widgets/admin_app_bar.dart';
import '../../../core/widgets/firebase_index_message.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SocialLinksAdminView extends ConsumerWidget {
  const SocialLinksAdminView({super.key});

  static const _predefinedPlatforms = [
    {
      'name': 'Facebook',
      'icon': Icons.facebook,
      'iconData': Icons.facebook,
    },
    {
      'name': 'Instagram',
      'icon': Icons.camera_alt,
      'iconData': Icons.camera_alt,
    },
    {
      'name': 'TikTok',
      'icon': Icons.video_library,
      'iconData': Icons.video_library,
    },
    {
      'name': 'WhatsApp',
      'icon': Icons.message,
      'iconData': Icons.message,
    },
    {
      'name': 'Phone',
      'icon': Icons.phone,
      'iconData': Icons.phone,
    },
    {
      'name': 'Email',
      'icon': Icons.email,
      'iconData': Icons.email,
    },
    {
      'name': 'Website',
      'icon': Icons.language,
      'iconData': Icons.language,
    },
    {
      'name': 'Custom',
      'icon': Icons.add_circle_outline,
      'iconData': Icons.add_circle_outline,
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final socialLinks = ref.watch(socialLinksStreamProvider);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.preview,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.preview,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: socialLinks.when(
                  data: (links) => SocialLinksDisplay(
                    socialLinks: links,
                    isPreview: true,
                    maxWidth: 400,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => FirebaseIndexMessage(
                    error: error,
                    stackTrace: stack,
                    onRefresh: () => ref.invalidate(socialLinksStreamProvider),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Scaffold(
            appBar: AdminAppBar(
              backPath: '/admin',
              title: l10n.socialLinks,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showHeaderDialog(context, ref),
                  tooltip: l10n.editHeader,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showPlatformSelectionDialog(context, ref),
                  tooltip: l10n.addNewLink,
                ),
              ],
            ),
            body: socialLinks.when(
              data: (links) {
                final nonHeaderLinks = links.where((link) => !link.isHeader).toList()
                  ..sort((a, b) => a.order.compareTo(b.order));

                if (nonHeaderLinks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.noSocialLinks),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _showPlatformSelectionDialog(context, ref),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.addSocialLink),
                        ),
                      ],
                    ),
                  );
                }

                return ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: nonHeaderLinks.length,
                  onReorder: (oldIndex, newIndex) => _handleReorder(
                    context,
                    ref,
                    nonHeaderLinks,
                    oldIndex,
                    newIndex,
                  ),
                  itemBuilder: (context, index) {
                    final link = nonHeaderLinks[index];
                    return Card(
                      key: ValueKey(link.id),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: _buildLeadingIcon(context,link),
                        title: Text(link.name),
                        subtitle: Text(
                          link.url ?? '',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showAddEditDialog(context, ref, link, _getPlatformByName(link.name)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteDialog(context, ref, link.id),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.drag_handle,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => FirebaseIndexMessage(
                error: error,
                stackTrace: stack,
                onRefresh: () => ref.invalidate(socialLinksStreamProvider),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleReorder(
    BuildContext context,
    WidgetRef ref,
    List<SocialLink> links,
    int oldIndex,
    int newIndex,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final service = ref.read(socialLinksServiceProvider);
      final movedLink = links[oldIndex];
      final updatedLinks = List<SocialLink>.from(links)..removeAt(oldIndex)..insert(newIndex, movedLink);

      // Update orders
      for (var i = 0; i < updatedLinks.length; i++) {
        final link = updatedLinks[i];
        if (link.order != i) {
          await service.updateSocialLink(link.copyWith(order: i));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorReorderingSocialLinks(e.toString()))),
        );
      }
    }
  }

  Future<void> _showHeaderDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final socialLinks = await ref.read(socialLinksStreamProvider.future);
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

    if (!context.mounted) return;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _HeaderDialog(header: header),
    );

    if (result != null) {
      try {
        final service = ref.read(socialLinksServiceProvider);
        final updatedHeader = header.copyWith(
          name: result['name'],
          nameHe: result['nameHe'],
        );

        // Check if header exists in socialLinks
        final headerExists = socialLinks.any((link) => link.isHeader && link.id == 'header');
        
        if (headerExists) {
          await service.updateSocialLink(updatedHeader);
        } else {
          // Create new header
          await service.addSocialLink(
            name: updatedHeader.name,
            nameHe: updatedHeader.nameHe,
            url: null,
            iconPath: null,
            order: -1,
            isHeader: true,
          );
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.headerUpdated)),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorSavingSocialLink(e.toString()))),
          );
        }
      }
    }
  }

  Map<String, dynamic>? _getPlatformByName(String name) {
    return _predefinedPlatforms.firstWhere(
      (platform) => platform['name'] == name,
      orElse: () => _predefinedPlatforms.last,
    );
  }

  Future<void> _showPlatformSelectionDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final platform = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectPlatform),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _predefinedPlatforms.map((platform) {
              return ListTile(
                leading: Icon(platform['icon'] as IconData),
                title: Text(platform['name'] as String),
                onTap: () => Navigator.pop(context, platform),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (platform != null && context.mounted) {
      await _showAddEditDialog(context, ref, null, platform);
    }
  }

  Future<void> _showAddEditDialog(
    BuildContext context,
    WidgetRef ref,
    SocialLink? existingLink,
    Map<String, dynamic>? platform,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddEditSocialLinkDialog(
        ref: ref,
        existingLink: existingLink,
        platform: platform,
      ),
    );

    if (result != null) {
      try {
        final service = ref.read(socialLinksServiceProvider);
        final name = result['name'] as String;
        final url = result['url'] as String?;
        final iconPath = result['iconPath'] as String?;
        final nameHe = result['nameHe'] as String?;

        // Check if it's a predefined platform
        final isPredefined = _predefinedPlatforms.any((p) => p['name'] == name);

        if (existingLink != null) {
          await service.updateSocialLink(
            existingLink.copyWith(
              name: name,
              nameHe: nameHe,
              url: url,
              // Only set iconPath for custom platforms
              iconPath: isPredefined ? '' : iconPath,
            ),
          );
        } else {
          await service.addSocialLink(
            name: name,
            nameHe: nameHe,
            url: url,
            // Only set iconPath for custom platforms
            iconPath: isPredefined ? '' : iconPath,
          );
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                existingLink == null ? l10n.socialLinkAdded : l10n.socialLinkUpdated,
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorSavingSocialLink(e.toString()))),
          );
        }
      }
    }
  }

  IconData _getIconForPlatform(String platform) {
    final predefined = _getPlatformByName(platform);
    return predefined?['iconData'] as IconData? ?? Icons.link;
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref, String linkId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteSocialLink),
        content: Text(l10n.deleteSocialLinkConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final service = ref.read(socialLinksServiceProvider);
        await service.deleteSocialLink(linkId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.socialLinkDeleted)),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorDeletingSocialLink(e.toString()))),
          );
        }
      }
    }
  }

  Widget _buildLeadingIcon(BuildContext context, SocialLink link) {
    // First check if it's a predefined platform
    final predefinedPlatform = _getPlatformByName(link.name);
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: Center(
        child: predefinedPlatform != null
          ? Icon(
              predefinedPlatform['iconData'] as IconData,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )
          : link.iconPath != null && link.iconPath!.isNotEmpty
            ? ClipOval(
                child: Image.network(
                  link.iconPath!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.link,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : Icon(
                Icons.link,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
      ),
    );
  }
}

class _AddEditSocialLinkDialog extends StatefulWidget {
  final WidgetRef ref;
  final SocialLink? existingLink;
  final Map<String, dynamic>? platform;

  const _AddEditSocialLinkDialog({
    required this.ref,
    this.existingLink,
    this.platform,
  });

  @override
  State<_AddEditSocialLinkDialog> createState() => _AddEditSocialLinkDialogState();
}

class _AddEditSocialLinkDialogState extends State<_AddEditSocialLinkDialog> {
  late final TextEditingController nameController;
  late final TextEditingController urlController;
  late final bool isCustom;
  String? selectedImagePath;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.existingLink?.name ?? widget.platform?['name'] as String? ?? '',
    );
    urlController = TextEditingController(
      text: widget.existingLink?.url ?? '',
    );
    isCustom = widget.platform?['name'] == 'Custom' || widget.platform == null;
    selectedImagePath = widget.existingLink?.iconPath;
  }

  @override
  void dispose() {
    nameController.dispose();
    urlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
      );
      
      if (image != null) {
        setState(() {
          selectedImagePath = image.path;
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorPickingImage(e.toString()))),
        );
      }
    }
  }

  Widget _buildCustomIconSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: l10n.platformName,
            hintText: l10n.enterPlatformName,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: _pickImage,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
            child: selectedImagePath != null
                ? ClipOval(
                    child: Image.network(
                      selectedImagePath!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 32,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 32,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.tapToSelectIcon,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.existingLink == null ? l10n.addSocialLink : l10n.editSocialLink),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCustom)
              _buildCustomIconSection()
            else
              ListTile(
                leading: Icon(widget.platform!['iconData'] as IconData),
                title: Text(widget.platform!['name'] as String),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: l10n.urlOrContact,
                hintText: l10n.enterUrlOrContact,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final name = isCustom ? nameController.text : widget.platform!['name'] as String;
            if ((isCustom && nameController.text.isEmpty) || urlController.text.isEmpty) {
              return;
            }

            Navigator.pop(context, {
              'name': name,
              'url': urlController.text,
              'iconPath': isCustom ? selectedImagePath : null,
            });
          },
          child: Text(widget.existingLink == null ? l10n.add : l10n.save),
        ),
      ],
    );
  }
}

class _HeaderDialog extends StatefulWidget {
  final SocialLink header;

  const _HeaderDialog({required this.header});

  @override
  State<_HeaderDialog> createState() => _HeaderDialogState();
}

class _HeaderDialogState extends State<_HeaderDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _nameHeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.header.name);
    _nameHeController = TextEditingController(text: widget.header.nameHe);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameHeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.editHeader),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.nameEnglish,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterName;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameHeController,
              decoration: InputDecoration(
                labelText: l10n.nameHebrew,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterHebrewName;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'name': _nameController.text,
                'nameHe': _nameHeController.text,
              });
            }
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
} 