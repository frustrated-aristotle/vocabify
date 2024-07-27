import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vocabify/word_details_page.dart';

class SearchScreen extends StatefulWidget {
  final List<QueryDocumentSnapshot<Object?>> wordData;

  const SearchScreen({super.key, required this.wordData});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<String> words = [];
  List<String> searchResults = [];

  @override
  void initState() {
    super.initState();
    getWords();
  }

  void getWords() {
    if (words.length < widget.wordData.length) {
      for (int i = 0; i < widget.wordData.length; i++) {
        words.add(widget.wordData[i]['word']);
      }
    }
  }

  void onQueryChanged(String query) {
    setState(() {
      searchResults = words
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
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
              onChanged: onQueryChanged,
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
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    onTap: () {
                      int wordIndex = words.indexOf(searchResults[index]);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WordDetailsPage(
                            word: widget.wordData[wordIndex]['word'],
                            explanation: widget.wordData[wordIndex]['explanation'],
                            sentence: widget.wordData[wordIndex]['sentence'],
                          ),
                        ),
                      );
                    },
                    title: Text(searchResults[index]),
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
