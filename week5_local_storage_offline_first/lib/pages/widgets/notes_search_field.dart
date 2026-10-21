import 'package:flutter/material.dart';

class NotesSearchField extends StatefulWidget {
  const NotesSearchField({
    super.key,
    required this.query,
    required this.onChanged,
  });

  final String query;
  final ValueChanged<String> onChanged;

  @override
  State<NotesSearchField> createState() => _NotesSearchFieldState();
}

class _NotesSearchFieldState extends State<NotesSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.query,
  );

  @override
  void didUpdateWidget(NotesSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Query bisa berubah dari luar (mis. tombol "Hapus pencarian" di empty
    // state), sehingga isi field harus ikut disesuaikan.
    if (widget.query != oldWidget.query && _controller.text != widget.query) {
      _controller.text = widget.query;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    setState(() {});
    widget.onChanged(value);
  }

  void _clear() {
    _controller.clear();
    _handleChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        onChanged: _handleChanged,
        decoration: InputDecoration(
          hintText: 'Cari judul catatan',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Hapus pencarian',
                  onPressed: _clear,
                ),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}
