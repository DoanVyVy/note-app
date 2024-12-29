import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class FolderList extends StatelessWidget {
  final Function(String) onFolderSelected;

  const FolderList({super.key, required this.onFolderSelected});

  @override
  Widget build(BuildContext context) {
    // This is a placeholder list of folders
    final folders = ['Personal', 'Work', 'Ideas', 'To-Do'];

    return AnimationLimiter(
      child: ListView.builder(
        itemCount: folders.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Icon(Icons.folder,
                        color: Theme.of(context).colorScheme.primary),
                    title: Text(folders[index]),
                    onTap: () => onFolderSelected(folders[index]),
                    trailing: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert,
                          color: Theme.of(context).colorScheme.primary),
                      onSelected: (String result) {
                        switch (result) {
                          case 'edit':
                            // Edit folder logic
                            break;
                          case 'delete':
                            // Delete folder logic
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
