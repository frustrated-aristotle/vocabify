import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WordDetailsPage extends StatefulWidget {
  final String word;
  final String explanation;
  final String sentence;

  WordDetailsPage({
    required this.word,
    required this.explanation,
    required this.sentence,
  });

  @override
  _WordDetailsPageState createState() => _WordDetailsPageState();
}

class _WordDetailsPageState extends State<WordDetailsPage> {
  late Future<Map<String, dynamic>> _wordDetails;
  final AudioPlayer player = AudioPlayer();
  String? _phoneticAudioUrl = "https://api.dictionaryapi.dev/media/pronunciations/en/example-us.mp3";

  @override
  void initState() {
    super.initState();
    _wordDetails = fetchWordDetails(widget.word);
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
    final response = await http.get(Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        final meanings = data[0]['meanings'] as List<dynamic>;
        final definitions = meanings.isNotEmpty ? meanings[0]['definitions'] as List<dynamic> : [];
        final definition = definitions.isNotEmpty
            ? definitions[0]['definition'] is String
            ? definitions[0]['definition'] as String
            : 'No definition found'
            : 'No definition found';

        final example = definitions.isNotEmpty && definitions[0].containsKey('example')
            ? definitions[0]['example'] is String
            ? definitions[0]['example'] as String
            : 'No example sentence found'
            : 'No example sentence found';

        final phonetics = data[0]['phonetics'] as List<dynamic>?;

        final phonetic = phonetics != null && phonetics.isNotEmpty
            ? phonetics[0]['text'] is String
            ? phonetics[0]['text'] as String
            : 'No phonetic found'
            : 'No phonetic found';

        _phoneticAudioUrl = phonetics != null && phonetics.isNotEmpty && phonetics[0].containsKey('audio')
            ? phonetics[0]['audio'] as String
            : null;

        return {
          'definition': definition,
          'example': example,
          'phonetic': phonetic,
        };
      }
    } else {
      throw Exception('Failed to load word details');
    }

    return {
      'definition': 'No definition found',
      'example': 'No example sentence found',
      'phonetic': 'No phonetic found',
    };
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Details'),
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
                        widget.word,
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
                    Text(
                      'User Explanation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 4, 118, 75),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.explanation,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'User Example Sentence',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 4, 118, 75),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.sentence,
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
                      'Official Definition',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 4, 118, 75),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      wordDetails['definition'],
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Official Example Sentence',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 4, 118, 75),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      wordDetails['example'],
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
