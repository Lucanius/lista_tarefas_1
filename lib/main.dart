import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class Note {
  final String title;
  final String text;
  final Color color;

  Note({required this.title, required this.text, required this.color});
}

class NotesModel extends ChangeNotifier {
  List<Note> _notes = [];

  List<Note> get notes => _notes;

  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
  }

  void editNote(int index, Note editedNote) {
    _notes[index] = editedNote;
    notifyListeners();
  }

  void deleteNote(int index) {
    _notes.removeAt(index);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo).copyWith(secondary: Colors.pinkAccent),
      ),
      home: ChangeNotifierProvider(
        create: (context) => NotesModel(),
        child: NotesScreen(),
      ),
    );
  }
}

class NotesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Notes'),
      ),
      body: Consumer<NotesModel>(
        builder: (context, notesModel, child) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: notesModel.notes.length,
            itemBuilder: (context, index) {
              final note = notesModel.notes[index];
              return NoteCard(
                note: note,
                onEdit: () => _editNote(context, notesModel, index),
                onDelete: () => _deleteNote(context, notesModel, index),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNote(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _addNote(BuildContext context) async {
    final newNote = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditScreen(),
      ),
    );

    if (newNote != null) {
      Provider.of<NotesModel>(context, listen: false).addNote(newNote);
    }
  }

  void _editNote(BuildContext context, NotesModel notesModel, int index) async {
    final editedNote = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditScreen(initialNote: notesModel.notes[index]),
      ),
    );

    if (editedNote != null) {
      notesModel.editNote(index, editedNote);
    }
  }

  void _deleteNote(BuildContext context, NotesModel notesModel, int index) {
    notesModel.deleteNote(index);
  }
}

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  NoteCard({required this.note, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: note.color,
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onEdit,
        onLongPress: onDelete,
        child: Container(
          width: double.infinity,
          height: 100.0,
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
              SizedBox(height: 8.0),
              Text(
                note.text,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoteEditScreen extends StatefulWidget {
  final Note? initialNote;

  NoteEditScreen({Key? key, this.initialNote}) : super(key: key);

  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _textController;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialNote?.title ?? '');
    _textController = TextEditingController(text: widget.initialNote?.text ?? '');
    _selectedColor = widget.initialNote?.color ?? Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialNote == null ? 'Add Note' : 'Edit Note'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _textController,
                decoration: InputDecoration(labelText: 'Note Text'),
                maxLines: 5,
              ),
              SizedBox(height: 16.0),
              Text('Select Color:'),
              SizedBox(height: 8.0),
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    _buildColorButton(Colors.yellow),
                    _buildColorButton(Colors.blue),
                    _buildColorButton(Colors.green),
                    _buildColorButton(Colors.pink),
                    _buildColorButton(Colors.purple),
                    _buildColorButton(Colors.black),
                    _buildColorButton(Colors.amber),
                    _buildColorButton(Colors.lightBlue),
                    _buildColorButton(Colors.orange),
                    _buildColorButton(Colors.red),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _saveNote(),
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () => _selectColor(color),
      child: Container(
        width: 40.0,
        height: 40.0,
        color: color,
        margin: EdgeInsets.all(4.0),
      ),
    );
  }

  void _selectColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final text = _textController.text.trim();

    if (title.isNotEmpty && text.isNotEmpty) {
      final editedNote = Note(title: title, text: text, color: _selectedColor);
      Navigator.pop(context, editedNote);
    }
  }
}
