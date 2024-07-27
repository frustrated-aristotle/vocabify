import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vocabify/game_page.dart';
import 'package:vocabify/local_notifications.dart';
import 'Search/general_search.dart';
//import 'word_details_page.dart';
import 'package:vocabify/Word Details/word_details_page.dart';
import 'add_word_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Database/database_helper.dart'; // Import the DatabaseHelper

class DictionaryHomePage extends StatefulWidget {
  @override
  _DictionaryHomePageState createState() => _DictionaryHomePageState();
}

class _DictionaryHomePageState extends State<DictionaryHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String userId;
  late List<QueryDocumentSnapshot> data;
  var _selectedIndex = 0;
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Instantiate DatabaseHelper
  List<String> words = [];

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    userId = _auth.currentUser!.uid;
    getWords();
    _requestNotificationPermission();
  }

  void getWords() async{
    //words = await _dbHelper.getWords;
  }

  Future<void> _requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Notification Permission'),
          content: Text('This app needs notification access to send you updates.'),
          actions: <Widget>[
            TextButton(
              child: Text('Deny'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Allow'),
              onPressed: () async {
                Navigator.of(context).pop();
                await Permission.notification.request();
              },
            ),
          ],
        ),
      );
    }
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DictionaryHomePage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GeneralSearchScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddWordPage()),
        );
        break;
      case 3:
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GamePage(wordData: data)),
        );
        break;
      default:
        break;
    }
  }


  Future<void> _showRandomWord() async {
    final wordData = "await _dbHelper.getRandomWord();";
    if (wordData != null) {
      LocalNotifications.showSimpleNotification(
        title: 'Random Word',
        body: 'Word: ', // ${wordData['word']}\nExplanation: ${wordData['explanation']}',
        payload: 'payload',
      );
    } else {
      LocalNotifications.showSimpleNotification(
        title: 'No Word Found',
        body: 'No word found in the database.',
        payload: 'payload',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('vocabify'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('words').where('uid', isEqualTo: userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No words found.'));
          }

          final words = snapshot.data!.docs;
          data = words;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 3,
              ),
              itemCount: words.length,
              itemBuilder: (context, index) {
                //These are word documents
                final wordData = words[index];
                return GestureDetector(
                  onTap: () {
                    print("Word data basically is : " + wordData.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WordDetailsPage(
                          wordData: wordData,
                          docID: wordData.id,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: Color.fromARGB(255, 4, 118, 75),
                    elevation: 4.0,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          wordData['word'],
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showRandomWord(); // Show a random word from the database
        },
        tooltip: 'Show Random Word',
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 4, 118, 75),
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 4, 118, 75),
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Color.fromARGB(255, 4, 118, 75),
            tooltip: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.games_rounded),
            label: 'Game',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 144, 238, 144),
        onTap: _onItemTapped,
      ),
    );
  }
}
