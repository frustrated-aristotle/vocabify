import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditWord extends StatefulWidget {
  final String docID;
  const EditWord({super.key, required this.docID});

  @override
  State<EditWord> createState() => _EditWordState();
}

class _EditWordState extends State<EditWord> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _wordController;
  final List<TextEditingController> _explanationControllers = [];
  final List<List<TextEditingController>> _sentenceControllers = [];

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController();
    _loadWordData();
  }

  Future<void> _loadWordData() async {
    try {
      final docSnapshot = await _firestore.collection('words').doc(widget.docID).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        _wordController.text = data['word'] ?? '';

        final explanations = data['explanations'] as List<dynamic>? ?? [];
        setState(() {
          _explanationControllers.clear();
          _sentenceControllers.clear();
          for (var explanation in explanations) {
            final explanationMap = explanation as Map<String, dynamic>;
            _explanationControllers.add(TextEditingController(text: explanationMap['text'] ?? ''));
            _sentenceControllers.add(
              (explanationMap['sentences'] as List<dynamic>? ?? [])
                  .map((sentence) => TextEditingController(text: sentence))
                  .toList(),
            );
          }
        });
      }
    } catch (e) {
      print('Error loading word data: $e');
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    for (var controller in _explanationControllers) {
      controller.dispose();
    }
    for (var sentences in _sentenceControllers) {
      for (var controller in sentences) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _addExplanation() {
    setState(() {
      _explanationControllers.add(TextEditingController());
      _sentenceControllers.add([]);
    });
  }

  void _removeExplanation(int index) {
    setState(() {
      _explanationControllers.removeAt(index);
      _sentenceControllers.removeAt(index);
    });
  }

  void _addSentence(int explanationIndex) {
    setState(() {
      _sentenceControllers[explanationIndex].add(TextEditingController());
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

      _firestore.collection('words').doc(widget.docID).update({
        'word': word,
        'explanations': explanationsMap.values.toList(),
      }).then((_) {
        Navigator.pop(context);
      }).catchError((error) {
        print('Error updating word: $error');
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

  InputDecoration get _textFieldDecoration {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Color.fromARGB(255, 4, 118, 75), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Word'),
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
                      'Edit Word',
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
                    decoration: _textFieldDecoration.copyWith(labelText: 'Word'),
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
                                  SizedBox(height: 20),
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
                                              decoration: _textFieldDecoration.copyWith(
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
