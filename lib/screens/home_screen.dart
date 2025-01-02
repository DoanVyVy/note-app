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
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Folder> _searchedFolders = [];
  List<Note> _searchedNotes = [];
  late User _currentUser;
  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is User) {
      _currentUser = args;
      _loadFolders();
    } else {
      _showToast('Error: User not provided');
      Navigator.pushReplacementNamed(context, '/login');
    }
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

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchedFolders = [];
        _searchedNotes = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final folders =
        await DatabaseHelper.instance.searchFolders(_currentUser.id!, query);
    final notes =
        await DatabaseHelper.instance.searchNotes(_currentUser.id!, query);

    setState(() {
      _searchedFolders = folders;
      _searchedNotes = notes;
    });
  }

  Widget _buildSearchResults() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_searchedFolders.isNotEmpty) ...[
              Text(
                'Folders',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: _searchedFolders.length,
                itemBuilder: (context, index) {
                  final folder = _searchedFolders[index];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFolder = folder.name;
                        _isSearching = false;
                        _searchController.clear();
                      });
                      _loadNotes(folder.id!);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(folder.color),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          folder.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
            if (_searchedNotes.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _searchedNotes.length,
                itemBuilder: (context, index) {
                  final note = _searchedNotes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Color(note.color),
                    child: ListTile(
                      title: Text(
                        note.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        note.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () async {
                        // Navigate to note detail
                        final folder = _folders.firstWhere(
                          (f) => f.id == note.folderId,
                        );
                        setState(() {
                          _selectedFolder = folder.name;
                          _isSearching = false;
                          _searchController.clear();
                        });
                        await _loadNotes(folder.id!);
                      },
                    ),
                  );
                },
              ),
            ],
            if (_searchedFolders.isEmpty && _searchedNotes.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No results found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search folders and notes...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.blueGrey),
                ),
                style: const TextStyle(color: Colors.black),
                onChanged: _performSearch,
              )
            : Text(_selectedFolder ?? 'My Folders'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _searchedFolders = [];
                  _searchedNotes = [];
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _isSearching
          ? _buildSearchResults()
          : _selectedFolder == null
              ? FolderGrid(
                  folders: _folders,
                  onFolderSelected: (folder) {
                    setState(() {
                      _selectedFolder = folder.name;
                    });
                    _loadNotes(folder.id!);
                  },
                  onFolderDeleted: (folder) async {
                    await DatabaseHelper.instance.deleteFolder(folder.id!);
                    _showToast('Folder deleted');
                    _loadFolders();
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
                  onNoteDeleted: (note) async {
                    await DatabaseHelper.instance.deleteNote(note.id!);
                    _showToast('Note deleted');
                    _loadNotes(note.folderId);
                  },
                  onNotesUpdated: () {
                    _loadNotes(_notes.first.folderId);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
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
                  _showToast('Folder added');
                  _loadFolders();
                } else {
                  // Add note
                  final currentFolder =
                      _folders.firstWhere((f) => f.name == _selectedFolder);
                  final newNote = Note(
                    title: textFieldController.text,
                    content: '',
                    color: pickerColor.value,
                    folderId: currentFolder.id!,
                    userId: _currentUser.id!,
                  );
                  await DatabaseHelper.instance.insertNote(newNote);
                  _showToast('Note added');
                  _loadNotes(currentFolder.id!);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
