import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'word_details_page.dart';

class GamePage extends StatefulWidget {
  final List<QueryDocumentSnapshot<Object?>> wordData;
  const GamePage({super.key, required this.wordData});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int index = 0;
  bool showMeaning = false;
  int numberOfWords = 1;
  bool selectionMade = false;
  bool isCompleted = false;
  bool isDialogOpen = false; // State variable to track if dialog is open
  List<int> truePredictions = [];
  List<int> falsePredictions = [];
  List<int> selectedWords = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showWordSelectionDialog());
  }

  void selectWords() {
    Random rand = Random();
    while (selectedWords.length < numberOfWords) {
      int temp = rand.nextInt(widget.wordData.length);
      if (!selectedWords.contains(temp)) {
        selectedWords.add(temp);
      }
    }
  }

  void getNextWord() {
    setState(() {
      if (index < selectedWords.length - 1) {
        index++;
      } else if (falsePredictions.isNotEmpty) {
        selectedWords.addAll(falsePredictions);
        falsePredictions.clear();
        index++;
      } else {
        isCompleted = true;
      }
      showMeaning = false;
    });
  }

  Future<void> _showWordSelectionDialog() async {
    if (isDialogOpen) return; // Prevent opening multiple dialogs

    isDialogOpen = true;
    int selectedNumber = numberOfWords;
    await showDialog<int>(
      context: context,
      barrierDismissible: false, // Prevents closing the dialog when tapping outside
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            _showWordSelectionDialog();
            return false;
          },
          child: AlertDialog(
            title: Text('Select Number of Words'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Slider(
                      value: selectedNumber.toDouble(),
                      min: 1,
                      max: widget.wordData.length.toDouble(),
                      divisions: widget.wordData.length - 1,
                      label: selectedNumber.toString(),
                      onChanged: (double value) {
                        setState(() {
                          selectedNumber = value.toInt();
                        });
                      },
                    ),
                    Text('$selectedNumber'),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DictionaryHomePage()));
                },
              ),
              ElevatedButton(
                child: Text('Start'),
                onPressed: () {
                  Navigator.of(context).pop(selectedNumber);
                },
              ),
            ],
          ),
        );
      },
    ).then((value) {
      isDialogOpen = false;
      if (value != null) {
        setState(() {
          numberOfWords = value;
          showMeaning = false;
          selectionMade = true;
          isCompleted = false;
          truePredictions.clear();
          falsePredictions.clear();
          selectedWords.clear();
          index = 0;
          selectWords();
        });
      } else {
        _showWordSelectionDialog(); // Re-show the dialog if no value is selected
      }
    });
  }

  Widget buildWordCard(BuildContext context, Map<String, dynamic> wordData) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: IntrinsicWidth(
        child: Column(
          children: [
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCompleted) ...[
                      Center(
                        child: Text(
                          "Completed",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ] else ...[
                      Center(
                        child: Text(
                          wordData['word'],
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (showMeaning) ...[
                        Divider(height: 10, color: Colors.grey),
                        SizedBox(height: 8),
                        Center(
                          child: Text(
                            "Meaning",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            '${wordData['explanation']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Divider(height: 20),
                        SizedBox(height: 16),
                        Center(
                          child: Text("Was your prediction true?"),
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                // True Prediction Button
                                onPressed: () {
                                  truePredictions.add(index);
                                  getNextWord();
                                },
                                child: Icon(Icons.check_rounded),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  textStyle: TextStyle(fontSize: 18),
                                  backgroundColor: Color.fromARGB(255, 4, 118, 75),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              SizedBox(width: 20),
                              TextButton(
                                // False Prediction Button
                                onPressed: () {
                                  falsePredictions.add(selectedWords[index]);
                                  getNextWord();
                                },
                                child: Icon(Icons.clear_rounded),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  textStyle: TextStyle(fontSize: 18),
                                  backgroundColor: Color.fromARGB(255, 4, 118, 75),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Center(
                          child: Text("Say what does it mean?"),
                        ),
                        SizedBox(height: 8),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                showMeaning = !showMeaning;
                              });
                            },
                            child: Text("Show Meaning"),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              textStyle: TextStyle(fontSize: 18),
                              backgroundColor: Color.fromARGB(255, 4, 118, 75),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ]
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 64),
            if (!isCompleted) ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WordDetailsPage(
                        word: widget.wordData[selectedWords[index]]['word'],
                        explanation: widget.wordData[selectedWords[index]]['explanation'],
                        sentence: widget.wordData[selectedWords[index]]['sentence'],
                      ),
                    ),
                  );
                },
                child: Text("Word's Detail"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                  backgroundColor: Color.fromARGB(255, 4, 118, 75),
                  foregroundColor: Colors.white,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.wordData.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Game Page"),
        ),
        body: Center(
          child: Text("No words available"),
        ),
      );
    }

    if (!selectionMade) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Game Page"),
        ),
        body: Center(
          child: GestureDetector(
            onTap: _showWordSelectionDialog,
            child: CircularProgressIndicator(), // Show a loading indicator while waiting for the selection
          ),
        ),
      );
    }

    final wordData = widget.wordData[selectedWords[index]].data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Game Page"),
      ),
      body: GestureDetector(
        onTap: () {
          if (!isDialogOpen) {
            _showWordSelectionDialog();
          }
        },
        child: Center(
          child: SingleChildScrollView(
            child: buildWordCard(context, wordData),
          ),
        ),
      ),
    );
  }
}
