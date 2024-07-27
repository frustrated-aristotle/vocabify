import 'package:flutter/material.dart';
import 'package:vocabify/Database/database_helper.dart';
import 'package:vocabify/word_detail_page.dart'; // Updated page where detailed word info is shown

class GeneralSearchScreen extends StatefulWidget {
  @override
  _GeneralSearchScreenState createState() => _GeneralSearchScreenState();
}

class _GeneralSearchScreenState extends State<GeneralSearchScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  // Function to format the word
  String formatWord(String word) {
    return word
        .split('_')
        .map((s) => s[0].toUpperCase() + s.substring(1))
        .join(' ');
  }

  // Function to fetch official definition and sentence
  Future<Map<String, String>> fetchWordDetails(String word) async {
    // Replace this with actual logic to fetch definition and sentence
    // Example dummy implementation:
    return {
      'definition': 'Definition of $word.',
      'sentence': 'This is an example sentence using the word $word.'
    };
  }

  // Search for words based on query
  void _searchWords(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final results = await _dbHelper.searchWords(query);

    setState(() {
      _searchResults = results.map((word) {
        return {
          'word': word,
          'formatted': formatWord(word),
          'explanation': 'No user explanation available.', // Placeholder, update as needed
          'sentence': 'No user sentence available.' // Placeholder, update as needed
        };
      }).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _searchWords,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search words...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    onTap: () async {
                      final word = result['word'];
                      final formattedWord = result['formatted'];

                      // Fetch official definition and sentence
                      final wordDetails = await fetchWordDetails(word);
                      final definition = wordDetails['definition'] ?? 'No definition available.';
                      final sentence = wordDetails['sentence'] ?? 'No example sentence available.';
                      final audio = wordDetails['audio'] ?? 'd';

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WordDetailPage(
                            word: formattedWord,
                            officialDefinition: definition,
                            officialSentence: sentence,
                            audio : audio,
                          ),
                        ),
                      );
                    },
                    title: Text(result['formatted']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
