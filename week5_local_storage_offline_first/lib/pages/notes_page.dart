import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/local/note.dart';
import '../data/providers.dart';
import 'widgets/add_note_dialog.dart';
import 'widgets/note_tile.dart';
import 'widgets/notes_empty_state.dart';
import 'widgets/notes_search_field.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan'),
        actions: [
          const DirtyBadge(),
          IconButton(
            icon: const Icon(Icons.cloud_sync_outlined),
            tooltip: 'Sinkronkan catatan',
            onPressed: () => _syncNow(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.article_outlined),
            tooltip: 'Postingan (cache-first)',
            onPressed: () => context.push('/posts'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: const _NotesBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _promptAddNote(context, ref),
        tooltip: 'Tambah catatan',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Memilih antara keadaan kosong, galat, atau daftar yang bisa dicari.
class _NotesBody extends ConsumerWidget {
  const _NotesBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(notesProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorView(message: '$error'),
          data: (notes) =>
              notes.isEmpty ? const _EmptyView() : const _SearchableNotes(),
        );
  }
}

/// Kolom pencarian + hasil saring. Tidak menyentuh database.
class _SearchableNotes extends ConsumerWidget {
  const _SearchableNotes();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleAsync = ref.watch(visibleNotesProvider);
    final query = ref.watch(noteQueryProvider);

    return Column(
      children: [
        NotesSearchField(
          query: query,
          onChanged: ref.read(noteQueryProvider.notifier).set,
        ),
        Expanded(
          child: visibleAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _ErrorView(message: '$error'),
            data: (visible) => visible.isEmpty
                ? NotesEmptyState(
                    query: query,
                    onClear: ref.read(noteQueryProvider.notifier).clear,
                  )
                : _NotesList(notes: visible),
          ),
        ),
      ],
    );
  }
}

class _NotesList extends ConsumerWidget {
  const _NotesList({required this.notes});

  final List<Note> notes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      itemCount: notes.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteTile(
          note: note,
          onTap: () => context.push('/note/${note.id}'),
          onDelete: () => ref.read(notesProvider.notifier).remove(note.id!),
        );
      },
    );
  }
}

class DirtyBadge extends ConsumerWidget {
  const DirtyBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dirty = ref.watch(dirtyCountProvider).value ?? 0;
    if (dirty == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Badge.count(
        count: dirty,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.cloud_upload_outlined),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note_alt_outlined, size: 48),
          SizedBox(height: 12),
          Text('Belum ada catatan. Tekan + untuk menambah.'),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat catatan:\n$message',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _promptAddNote(BuildContext context, WidgetRef ref) async {
  final title = await showDialog<String>(
    context: context,
    builder: (_) => const AddNoteDialog(),
  );

  if (title == null) return;
  await ref.read(notesProvider.notifier).add(title: title);
}

Future<void> _syncNow(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);

  if (ref.read(forceOfflineProvider)) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Mode offline aktif - sync dilewati.')),
    );
    return;
  }

  final synced = await ref
      .read(syncServiceProvider)
      .syncNotes(ref.read(noteRepositoryProvider));
  ref.invalidate(notesProvider);
  ref.invalidate(dirtyCountProvider);

  messenger.showSnackBar(
    SnackBar(
      content: Text(
        synced == 0
            ? 'Tidak ada catatan yang perlu disinkronkan.'
            : '$synced catatan tersinkron.',
      ),
    ),
  );
}
