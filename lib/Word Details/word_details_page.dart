import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vocabify/Edit%20Word/edi_word_page.dart';

import '../all_sentences.dart';

class WordDetailsPage extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> wordData;
  final String docID;

  WordDetailsPage({
    required this.wordData,
    required this.docID,
  });

  @override
  _WordDetailsPageState createState() => _WordDetailsPageState();
}

class _WordDetailsPageState extends State<WordDetailsPage> {
  late Future<Map<String, dynamic>> _wordDetails;
  final AudioPlayer player = AudioPlayer();
  late Future<Map<String, dynamic>?> _bookSentences;
  late List<String> bookSentences = [];
  String? _phoneticAudioUrl;

  @override
  void initState() {
    super.initState();
    _wordDetails = fetchWordDetails(widget.wordData['word']);
    _bookSentences = fetchBookSentences();
  }

  Future<Map<String, dynamic>?> fetchBookSentences() async {
    String word = widget.wordData['word'];
    try {
      final response = await http.get(Uri.parse('https://books-db.a-secgeler.workers.dev/search?word=$word'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Check if 'sentences' exists and is not empty
        if (data['sentences'] != null && data['sentences'] is List) {
          // Optionally, you can process or print the sentences
          if (data['sentences'].isNotEmpty) {
            print(data['sentences'][0]['sentence']);
            print(data['sentences'][0]['bookTitle']);
            print(data['sentences'].length);
          }
          return data; // Return the complete data map
        } else {
          print('No sentences found');
          return {}; // Return an empty map if 'sentences' is null or not a list
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        return {}; // Return an empty map if the response status is not 200
      }
    } catch (e) {
      print('Error fetching book sentences: $e');
      return {}; // Return an empty map if an error occurs
    }
  }

  void fetchBookWords() async {

  }

  void _playAudio(BuildContext context) async {
    if (_phoneticAudioUrl != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Playing phonetic audio')),
      );
      await player.play(UrlSource(_phoneticAudioUrl!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No phonetic audio available')),
      );
    }
  }

  Future<Map<String, dynamic>> fetchWordDetails(String word) async {
    final response = await http.get(
        Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        final meanings = data[0]['meanings'] as List<dynamic>;
        final definitions = meanings.isNotEmpty
            ? meanings[0]['definitions'] as List<dynamic>
            : [];
        final phonetics = data[0]['phonetics'] as List<dynamic>?;

        final phonetic = phonetics != null && phonetics.isNotEmpty
            ? phonetics[0]['text'] as String
            : 'No phonetic found';

        _phoneticAudioUrl = phonetics != null &&
            phonetics.isNotEmpty &&
            phonetics[0].containsKey('audio')
            ? phonetics[0]['audio'] as String
            : null;

        return {
          'definitions': definitions,
          'phonetic': phonetic,
        };
      }
    } else {
      throw Exception('Failed to load word details');
    }

    return {
      'definitions': [],
      'phonetic': 'No phonetic found',
    };
  }

  void _editWord() {
    // Your edit logic here
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditWord(docID: widget.docID)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _wordDetails,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final wordDetails = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            widget.wordData["word"],
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            wordDetails['phonetic'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _playAudio(context);
                          },
                          child: Text("Listen"),
                        ),
                        Divider(
                          height: 30,
                          thickness: 2,
                          color: Colors.grey[300],
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Explanations',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 4, 118, 75),
                                  ),
                                ),
                                SizedBox(height: 8),
                                ...widget.wordData['explanations']
                                    .map<Widget>((explanation) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: Card(
                                      margin: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              explanation['text'],
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            ...explanation['sentences']
                                                .map<Widget>((sentence) {
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 4.0),
                                                child: Text(
                                                  sentence,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                Divider(
                                  height: 30,
                                  thickness: 2,
                                  color: Colors.grey[300],
                                ),
                                Text(
                                  'Additional Information',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 4, 118, 75),
                                  ),
                                ),
                                SizedBox(height: 8),
                                ...wordDetails['definitions']
                                    .map<Widget>((definition) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: Card(
                                      margin: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              definition['definition'],
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            if (definition.containsKey('example'))
                                              ...definition['example']
                                                  .split('. ')
                                                  .map<Widget>((sentence) {
                                                return Padding(
                                                  padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4.0),
                                                  child: Text(
                                                    sentence,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontStyle: FontStyle.italic,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                Text(
                                  'Sentences from Books',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 4, 118, 75),
                                  ),
                                ),
                                FutureBuilder<Map<String, dynamic>?>(
                                  future: _bookSentences,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    }
                                    if (snapshot.hasError) {
                                      return Center(child: Text('Error: ${snapshot.error}'));
                                    }
                                    if (snapshot.data == null || snapshot.data!.isEmpty) {
                                      return Center(child: Text('No sentences available.'));
                                    }
                                    final sentences = snapshot.data!['sentences'];
                                    final displayedSentences = sentences.take(5).toList();

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ...displayedSentences.map<Widget>((sentence) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              child: ListTile(
                                                title: Text(sentence['sentence']),
                                                subtitle: Text(sentence['bookTitle']),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        if (sentences.length > 5)
                                          ElevatedButton(
                                            onPressed: () {
                                              // Implement navigation to the new page with all sentences
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => AllSentencesPage(
                                                    sentences: sentences,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Text('Show More'),
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                              EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                              textStyle: TextStyle(fontSize: 18),
                                              backgroundColor: Color.fromARGB(255, 4, 118, 75),
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: FloatingActionButton(
                onPressed: _editWord,
                child: Icon(Icons.edit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


