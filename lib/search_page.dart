import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vocabify/word_details_page.dart';

/// Flutter code sample for [SearchBar].
class SearchBarApp extends StatefulWidget {
  final List<QueryDocumentSnapshot<Object?>> wordData;

  const SearchBarApp({super.key, required this.wordData});

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

class _SearchBarAppState extends State<SearchBarApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light);

    return MaterialApp(
      theme: themeData,
      home: Scaffold(
        appBar: AppBar(title: const Text('Search Bar Sample')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  padding: const MaterialStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0)),
                  onTap: () {
                    controller.openView();
                  },
                  onChanged: (_) {
                    controller.openView();
                  },
                  leading: const Icon(Icons.search),
                  trailing: <Widget>[
                    Tooltip(
                      message: 'Change brightness mode',
                      child: IconButton(
                        isSelected: isDark,
                        onPressed: () {
                          setState(() {
                            isDark = !isDark;
                          });
                        },
                        icon: const Icon(Icons.wb_sunny_outlined),
                        selectedIcon: const Icon(Icons.brightness_2_outlined),
                      ),
                    )
                  ],
                );
              }, suggestionsBuilder:
              (BuildContext context, SearchController controller) {
            return List<ListTile>.generate(5, (int index) {
              final String item = widget.wordData[index]['word'];
              return ListTile(
                title: Text(item),
                onTap: () {
                  setState(() {
                    controller.closeView(item);
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WordDetailsPage(
                      explanation: widget.wordData[index]['explanation'],
                    sentence: widget.wordData[index]['sentence'],
                    word: widget.wordData[index]['word'],)),
                  );
                },
              );
            });
          }),
        ),
      ),
    );
  }
}
