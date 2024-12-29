import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:note_app/models.dart';
import '../database_helper.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late Color _noteColor;
  int? _noteId;
  late int _folderId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _noteColor = Colors.white;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null && modalRoute.settings.arguments != null) {
      // Kiểm tra và xử lý dữ liệu
      final args = modalRoute.settings.arguments as Map<String, dynamic>;

      // Chuyển đổi Map thành Note
      final note = Note.fromMap(args);

      // Gán giá trị vào các biến
      _titleController.text = note.title;
      _contentController.text = note.content;
      _noteColor = Color(note.color);
      _noteId = note.id;
      _folderId = note.folderId;
    } else {
      // Xử lý khi không có arguments
      _showToast("No note data provided.");
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _saveNote() async {
    if (_noteId != null) {
      final updatedNote = Note(
        id: _noteId,
        title: _titleController.text,
        content: _contentController.text,
        color: _noteColor.value,
        folderId: _folderId,
        userId: 1, // Thay thế bằng userId thực tế của bạn
      );

      await DatabaseHelper.instance.updateNote(updatedNote);
      _showToast('Note updated successfully');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _noteColor,
      appBar: AppBar(
        title: const Text('Edit Note'),
        backgroundColor: _noteColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
            ),
            const Divider(color: Colors.black26),
            Expanded(
              child: TextField(
                controller: _contentController,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Start typing...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: _noteColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.format_bold),
              onPressed: () {
                // Implement bold text formatting
              },
            ),
            IconButton(
              icon: const Icon(Icons.format_italic),
              onPressed: () {
                // Implement italic text formatting
              },
            ),
            IconButton(
              icon: const Icon(Icons.format_list_bulleted),
              onPressed: () {
                // Implement bullet list
              },
            ),
            IconButton(
              icon: const Icon(Icons.color_lens),
              onPressed: () {
                _showColorPicker(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _noteColor,
              onColorChanged: (Color color) {
                setState(() {
                  _noteColor = color;
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
