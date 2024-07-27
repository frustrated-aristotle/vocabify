import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // Optional if you want to play audio
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WordDetailPage extends StatefulWidget {
  final String word;
  final String officialDefinition;
  final String officialSentence;
  final String audio;
  final String? userExplanation;
  final String? userSentence;

  WordDetailPage({
    required this.word,
    required this.officialDefinition,
    required this.officialSentence,
    required this.audio,
    this.userExplanation,
    this.userSentence,
  });

  @override
  _WordDetailPageState createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage> {
  late TextEditingController _wordController;
  final List<TextEditingController> _explanationControllers = [];
  final List<List<TextEditingController>> _sentenceControllers = [];
  bool _isAdded = false;
  final AudioPlayer _player = AudioPlayer();
  String? _phoneticAudioUrl = ""; // Placeholder URL

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController(text: widget.word);
    _addExplanation(); // Initialize with one explanation field
  }

  void _playAudio(BuildContext context) async {
    _phoneticAudioUrl = widget.audio;
    if (_phoneticAudioUrl != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Playing phonetic audio')),
      );
      await _player.play(UrlSource(_phoneticAudioUrl!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No phonetic audio available')),
      );
    }
  }

  void _addExplanation() {
    setState(() {
      _explanationControllers.add(TextEditingController());
      _sentenceControllers.add([TextEditingController()]); // Initialize with one sentence field
    });
  }

  void _addSentence(int explanationIndex) {
    setState(() {
      _sentenceControllers[explanationIndex].add(TextEditingController());
    });
  }

  void _removeExplanation(int index) {
    setState(() {
      _explanationControllers.removeAt(index);
      _sentenceControllers.removeAt(index);
    });
  }

  void _removeSentence(int explanationIndex, int sentenceIndex) {
    setState(() {
      _sentenceControllers[explanationIndex].removeAt(sentenceIndex);
    });
  }

  void _saveWord() {
    final word = _wordController.text;
    final explanations = _explanationControllers.map((controller) => controller.text).toList();
    final sentences = _sentenceControllers
        .map((controllers) => controllers.map((controller) => controller.text).toList())
        .toList();

    // Validate
    if (word.isNotEmpty &&
        explanations.every((e) => e.isNotEmpty) &&
        sentences.every((s) => s.isNotEmpty)) {
      // Constructing the explanations map
      final explanationsMap = explanations.asMap().map((index, explanation) => MapEntry(
        index,
        {'text': explanation, 'sentences': sentences[index]},
      ));

      FirebaseFirestore.instance.collection('words').add({
        'word': word,
        'officialDefinition': widget.officialDefinition,
        'officialSentence': widget.officialSentence,
        'explanations': explanationsMap.values.toList(),
        'uid': FirebaseAuth.instance.currentUser!.uid,
      }).then((doc) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'words': FieldValue.arrayUnion([doc.id])
        }).then((_) {
          Navigator.pop(context);
        });
      });
    } else {
      // Handle validation error
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Error'),
          content: Text(
              'Please fill out all fields. Each explanation must have at least one sentence.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.word),
        actions: [
          IconButton(
            icon: Icon(_isAdded ? Icons.check : Icons.add),
            onPressed: () => _saveWord(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      widget.word,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (_phoneticAudioUrl != null)
                    TextButton(
                      onPressed: () => _playAudio(context),
                      child: Text("Listen"),
                    ),
                  SizedBox(height: 16),
                  Text(
                    'Official Definition',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 4, 118, 75),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.officialDefinition,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Official Sentence',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 4, 118, 75),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.officialSentence,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  Divider(
                    height: 30,
                    thickness: 2,
                    color: Colors.grey[300],
                  ),
                  Text(
                    'Your Explanations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 4, 118, 75),
                    ),
                  ),
                  SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      _explanationControllers.length,
                          (explanationIndex) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: _explanationControllers[explanationIndex],
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Add your explanation here...',
                                    ),
                                    maxLines: 2,
                                  ),
                                  SizedBox(height: 8),
                                  Column(
                                    children: List.generate(
                                      _sentenceControllers[explanationIndex].length,
                                          (sentenceIndex) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Stack(
                                          children: [
                                            TextField(
                                              controller: _sentenceControllers[explanationIndex][sentenceIndex],
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                hintText: 'Add your sentence here...',
                                              ),
                                              maxLines: 2,
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: IconButton(
                                                icon: Icon(Icons.remove_circle, color: Colors.red),
                                                onPressed: () => _removeSentence(explanationIndex, sentenceIndex),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () => _addSentence(explanationIndex),
                                    child: Text('Add Sentence'),
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      textStyle: TextStyle(fontSize: 18),
                                      backgroundColor: Color.fromARGB(255, 4, 118, 75),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => _removeExplanation(explanationIndex),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addExplanation,
                    child: Text('Add Explanation'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: TextStyle(fontSize: 18),
                      backgroundColor: Color.fromARGB(255, 4, 118, 75),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _saveWord,
                      icon: Icon(Icons.save, size: 24), // Replace with desired icon and size
                      label: Text('Save Word'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: TextStyle(fontSize: 18),
                        backgroundColor: Color.fromARGB(255, 4, 118, 75),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
