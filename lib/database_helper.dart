import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        color INTEGER NOT NULL,
        folder_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        FOREIGN KEY (folder_id) REFERENCES folders (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // User operations
  Future<User?> getUser(String username, String password) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User> insertUser(User user) async {
    final db = await database;
    final id = await db.insert('users', user.toMap());
    return User(
      id: id,
      username: user.username,
      password: user.password,
    );
  }

  Future<List<Folder>> getFolders(int userId) async {
    final db = await database;
    final maps = await db.query(
      'folders',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => Folder.fromMap(map)).toList();
  }

  Future<Folder> insertFolder(Folder folder) async {
    final db = await database;
    final id = await db.insert('folders', folder.toMap());
    return Folder(
      id: id,
      name: folder.name,
      color: folder.color,
      userId: folder.userId,
    );
  }

  Future<int> updateFolder(Folder folder) async {
    final db = await database;
    return db.update(
      'folders',
      folder.toMap(),
      where: 'id = ?',
      whereArgs: [folder.id],
    );
  }

  Future<int> deleteFolder(int id) async {
    final db = await database;
    return db.delete(
      'folders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Note>> getNotes(int folderId, int userId) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'folder_id = ? AND user_id = ?',
      whereArgs: [folderId, userId],
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  Future<Note> insertNote(Note note) async {
    final db = await database;
    final id = await db.insert('notes', note.toMap());
    return Note(
      id: id,
      title: note.title,
      content: note.content,
      color: note.color,
      folderId: note.folderId,
      userId: note.userId,
    );
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Folder>> searchFolders(int userId, String query) async {
    final db = await database;
    final maps = await db.query(
      'folders',
      where: 'user_id = ? AND name LIKE ?',
      whereArgs: [userId, '%$query%'],
    );
    return maps.map((map) => Folder.fromMap(map)).toList();
  }

  Future<List<Note>> searchNotes(int userId, String query) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'user_id = ? AND (title LIKE ? OR content LIKE ?)',
      whereArgs: [userId, '%$query%', '%$query%'],
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
