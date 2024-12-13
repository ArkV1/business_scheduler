import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/firebase_error_handler.dart';

class FirebaseIndexMessage extends ConsumerWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onRefresh;

  const FirebaseIndexMessage({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorInfo = FirebaseErrorInfo.fromError(error, stackTrace);

    if (!errorInfo.isIndexError) {
      return Center(
        child: Text('Error: ${errorInfo.message}'),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.build_circle_outlined,
              size: 64,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            Text(
              'One-time Setup Required',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorInfo.message,
              textAlign: TextAlign.center,
            ),
            if (errorInfo.indexUrl != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: errorInfo.indexUrl!));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Index URL copied to clipboard')),
                    );
                  }
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy Index URL'),
              ),
              const SizedBox(height: 16),
              Text(
                'Open the copied URL in your browser\n'
                'while logged in as Firebase admin',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              if (onRefresh != null) ...[
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Check if index is ready'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
} 