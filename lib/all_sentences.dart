import 'package:flutter/material.dart';

class AllSentencesPage extends StatelessWidget {
  final List<dynamic> sentences;

  AllSentencesPage({required this.sentences});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Sentences'),
        backgroundColor: Colors.white, // Set AppBar background color to white
        foregroundColor: Color.fromARGB(255, 4, 118, 75), // Set text color to match the theme
      ),
      body: Container(
        color: Colors.white, // Set background color of the body
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sentences from Books',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 4, 118, 75),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: sentences.length,
                itemBuilder: (context, index) {
                  final sentence = sentences[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 2.0, // Add elevation for shadow effect
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          sentence['sentence'],
                          style: TextStyle(fontSize: 16.0),
                        ),
                        subtitle: Text(
                          sentence['bookTitle'],
                          style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
