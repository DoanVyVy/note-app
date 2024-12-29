import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models.dart';
import '../screens/note_detail_screen.dart';

class NoteList extends StatelessWidget {
  final String folder;
  final List<Note> notes;
  final VoidCallback onBackPressed;
  final Function(Note) onNoteDeleted;
  final Function() onNotesUpdated;

  const NoteList({
    super.key,
    required this.folder,
    required this.notes,
    required this.onBackPressed,
    required this.onNoteDeleted,
    required this.onNotesUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: onBackPressed,
              ),
              Expanded(
                child: Text(
                  folder,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: notes.isEmpty
              ? Center(
                  child: Text(
                    'No notes available',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : AnimationLimiter(
                  child: ListView.builder(
                    itemCount: notes.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Card(
                              elevation: 0,
                              color: Color(note.color),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                title: Text(
                                  note.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  note.content,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      onPressed: () => onNoteDeleted(note),
                                    ),
                                    const Icon(Icons.arrow_forward_ios,
                                        size: 16),
                                  ],
                                ),
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NoteDetailScreen(
                                        note: note,
                                      ),
                                      settings: RouteSettings(
                                          arguments: note
                                              .toMap()), // Truyền Map thay vì Note
                                    ),
                                  );
                                  if (result == true) {
                                    onNotesUpdated();
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
