import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../widgets/folder_grid.dart';
import '../widgets/note_list.dart';
import '../database_helper.dart';
import '../models.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedFolder;
  List<Folder> _folders = [];
  List<Note> _notes = [];
  late User _currentUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentUser = ModalRoute.of(context)!.settings.arguments as User;
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final folders = await DatabaseHelper.instance.getFolders(_currentUser.id!);
    setState(() {
      _folders = folders;
    });
  }

  Future<void> _loadNotes(int folderId) async {
    final notes =
        await DatabaseHelper.instance.getNotes(folderId, _currentUser.id!);
    setState(() {
      _notes = notes;
    });
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<void> _showDeleteConfirmDialog(
      BuildContext context, String itemType, Function onDelete) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete $itemType'),
          content: Text('Are you sure you want to delete this $itemType?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                onDelete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_selectedFolder ?? 'My Folders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _selectedFolder == null
          ? FolderGrid(
              folders: _folders,
              onFolderSelected: (folder) {
                setState(() {
                  _selectedFolder = folder.name;
                });
                _loadNotes(folder.id!);
              },
              onFolderDeleted: (folder) {
                _showDeleteConfirmDialog(context, 'folder', () async {
                  await DatabaseHelper.instance.deleteFolder(folder.id!);
                  _showToast('Folder deleted successfully');
                  _loadFolders();
                });
              },
            )
          : NoteList(
              folder: _selectedFolder!,
              notes: _notes,
              onBackPressed: () {
                setState(() {
                  _selectedFolder = null;
                });
                _loadFolders();
              },
              onNoteDeleted: (note) {
                _showDeleteConfirmDialog(context, 'note', () async {
                  await DatabaseHelper.instance.deleteNote(note.id!);
                  _showToast('Note deleted successfully');
                  _loadNotes(note.folderId);
                });
              },
              onNotesUpdated: () {
                _loadNotes(_notes[0].folderId);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context);
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final TextEditingController textFieldController = TextEditingController();
    Color pickerColor = Colors.blue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_selectedFolder == null ? 'Add Folder' : 'Add Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textFieldController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText:
                      _selectedFolder == null ? 'Folder name' : 'Note title',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                child: const Text('Pick color'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Pick a color'),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: pickerColor,
                            onColorChanged: (Color color) {
                              pickerColor = color;
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
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                if (_selectedFolder == null) {
                  // Add folder
                  final newFolder = Folder(
                    name: textFieldController.text,
                    color: pickerColor.value,
                    userId: _currentUser.id!,
                  );
                  await DatabaseHelper.instance.insertFolder(newFolder);
                  _showToast('Folder added successfully');
                  _loadFolders();
                } else {
                  // Add note
                  final newNote = Note(
                    title: textFieldController.text,
                    content: '',
                    color: pickerColor.value,
                    folderId: _folders
                        .firstWhere((f) => f.name == _selectedFolder)
                        .id!,
                    userId: _currentUser.id!,
                  );
                  await DatabaseHelper.instance.insertNote(newNote);
                  _showToast('Note added successfully');
                  _loadNotes(_folders
                      .firstWhere((f) => f.name == _selectedFolder)
                      .id!);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
