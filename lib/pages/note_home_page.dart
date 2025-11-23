import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_note/firestore_helpper.dart';
import 'package:flutter_note/models/note_model.dart';
import 'package:flutter_note/pages/note_editor_page.dart';
import 'package:flutter_note/pages/note_update_page.dart';

class NoteHomePage extends StatefulWidget {
  const NoteHomePage({super.key});

  @override
  State<NoteHomePage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteHomePage> {
  //final DbHelper dbHelper = DbHelper.instance;
  final FirestoreHelper fsHelper = FirestoreHelper();

  List<NoteModel> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    // TODO: Load notes from database
    // Simulating database with sample data
    final noteList = await fsHelper.fetchNotes();

    setState(() {
      _notes = noteList;
    });
  }

  void _navigateToCreateNote() async {
    // Navigate to create note page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteEditorPage()),
    );

    // Reload notes after returning from create page
    if (result != null) {
      //_loadNotes();
    }
  }

  void _navigateToEditNote(NoteModel note) async {
    //Navigate to edit note page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteUpdatePage(note: note)),
    );

    // //Reload notes after returning from edit page
    // if (result != null) {
    //   _loadNotes();
    // }
  }

  void _deleteNote(String noteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                fsHelper.deleteNote(noteId.toString());
              });
              //_loadNotes();

              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Note deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Notes'), elevation: 0),
      body: _notes.isEmpty ? _buildEmptyState() : _buildStreamNoteList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateNote,
        tooltip: 'Create new note',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_add_outlined, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first note',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              note.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(DateTime.parse(note.createdAt)),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteNote(note.noteId),
            ),
            onTap: () => _navigateToEditNote(note),
          ),
        );
      },
    );
  }

  Widget _buildStreamNoteList() {
    return StreamBuilder<QuerySnapshot<NoteModel>>(
      stream: fsHelper.getNoteStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        } else {
          final notes = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes.elementAt(index).data();
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    note.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        note.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(DateTime.parse(note.createdAt)),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteNote(note.noteId),
                  ),
                  onTap: () => _navigateToEditNote(note),
                ),
              );
            },
          );
        }
      },
    );
  }
}