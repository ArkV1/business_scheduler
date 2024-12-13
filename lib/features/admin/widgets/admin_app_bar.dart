import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final String backPath;
  final bool automaticallyImplyLeading;

  const AdminAppBar({
    super.key,
    this.title,
    this.actions,
    required this.backPath,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: automaticallyImplyLeading 
        ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(backPath),
          )
        : null,
      title: title != null ? Text(title!) : null,
      actions: actions?.map((widget) => 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: widget,
            )
          ).toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 