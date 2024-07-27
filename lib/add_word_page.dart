import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddWordPage extends StatefulWidget {
  @override
  _AddWordPageState createState() => _AddWordPageState();
}

class _AddWordPageState extends State<AddWordPage> {
  final _wordController = TextEditingController();
  final List<TextEditingController> _explanationControllers = [];
  final List<List<TextEditingController>> _sentenceControllers = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final InputDecoration _textFieldDecoration = InputDecoration(
    border: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(
      borderSide:
          BorderSide(color: Color.fromARGB(255, 4, 118, 75), width: 2.0),
    ),
    labelStyle: TextStyle(color: Color.fromARGB(255, 4, 118, 75)),
  );

  @override
  void initState() {
    super.initState();
    _addExplanation(); // Initialize with one explanation field
  }

  void _addExplanation() {
    setState(() {
      _explanationControllers.add(TextEditingController());
      _sentenceControllers
          .add([TextEditingController()]); // Initialize with one sentence field
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
    final explanations =
        _explanationControllers.map((controller) => controller.text).toList();
    final sentences = _sentenceControllers
        .map((controllers) =>
            controllers.map((controller) => controller.text).toList())
        .toList();

    // Validate
    if (word.isNotEmpty &&
        explanations.every((e) => e.isNotEmpty) &&
        sentences.every((s) => s.isNotEmpty)) {
      // Constructing the explanations map
      final explanationsMap =
          explanations.asMap().map((index, explanation) => MapEntry(
                index,
                {'text': explanation, 'sentences': sentences[index]},
              ));

      _firestore.collection('words').add({
        'word': word,
        'explanations': explanationsMap.values.toList(),
        'uid': FirebaseAuth.instance.currentUser!.uid,
      }).then((doc) {
        _firestore
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
        title: Text('Add New Word'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Add a New Word',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Divider(
                    height: 30,
                    thickness: 2,
                    color: Colors.grey[300],
                  ),
                  TextField(
                    controller: _wordController,
                    decoration:
                        _textFieldDecoration.copyWith(labelText: 'Word'),
                  ),
                  SizedBox(height: 16),
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
                                    controller: _explanationControllers[
                                        explanationIndex],
                                    decoration: _textFieldDecoration.copyWith(
                                        labelText:
                                            'Explanation ${explanationIndex + 1}'),
                                    maxLines: 2,
                                  ),
                                  SizedBox(height: 8),
                                  Column(
                                    children: List.generate(
                                      _sentenceControllers[explanationIndex]
                                          .length,
                                      (sentenceIndex) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Stack(
                                          children: [
                                            TextField(
                                              controller: _sentenceControllers[
                                                      explanationIndex]
                                                  [sentenceIndex],
                                              decoration:
                                                  _textFieldDecoration.copyWith(
                                                      labelText:
                                                          'Sentence ${sentenceIndex + 1}'),
                                              maxLines: 2,
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: IconButton(
                                                icon: Icon(Icons.remove_circle,
                                                    color: Colors.red),
                                                onPressed: () =>
                                                    _removeSentence(
                                                        explanationIndex,
                                                        sentenceIndex),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _addSentence(explanationIndex),
                                    child: Text('Add Sentence'),
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                      textStyle: TextStyle(fontSize: 18),
                                      backgroundColor:
                                          Color.fromARGB(255, 4, 118, 75),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: Icon(Icons.remove_circle,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _removeExplanation(explanationIndex),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _addExplanation,
                    child: Text('Add Explanation'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: TextStyle(fontSize: 18),
                      backgroundColor: Color.fromARGB(255, 4, 118, 75),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveWord,
                      child: Text('Save Word'),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: TextStyle(fontSize: 18),
                        backgroundColor: Color.fromARGB(255, 4, 118, 75),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
