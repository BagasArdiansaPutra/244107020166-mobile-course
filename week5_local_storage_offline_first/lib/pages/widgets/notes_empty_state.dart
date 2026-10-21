import 'package:flutter/material.dart';

class NotesEmptyState extends StatelessWidget {
  const NotesEmptyState({super.key, required this.query, this.onClear});

  final String query;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48),
            const SizedBox(height: 12),
            Text(
              'Tidak ada catatan yang cocok dengan "$query".',
              textAlign: TextAlign.center,
            ),
            if (onClear != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onClear,
                child: const Text('Hapus pencarian'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
