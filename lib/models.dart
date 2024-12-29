class User {
  final int? id;
  final String username;
  final String password;

  User({this.id, required this.username, required this.password});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
    );
  }
}

class Folder {
  final int? id;
  final String name;
  final int color;
  final int userId;

  Folder(
      {this.id, required this.name, required this.color, required this.userId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'user_id': userId,
    };
  }

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      userId: map['user_id'],
    );
  }
}

class Note {
  final int? id;
  final String title;
  final String content;
  final int color;
  final int folderId;
  final int userId;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.folderId,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color,
      'folder_id': folderId,
      'user_id': userId,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      color: map['color'],
      folderId: map['folder_id'],
      userId: map['user_id'],
    );
  }
}
