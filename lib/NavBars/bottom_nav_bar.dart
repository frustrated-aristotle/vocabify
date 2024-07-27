import 'package:flutter/material.dart';

class BottomNavScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final Function(int) onItemTapped;

  BottomNavScaffold({
    required this.body,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 4, 118, 75),
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
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
        currentIndex: currentIndex,
        selectedItemColor: Color.fromARGB(255, 144, 238, 144),
        onTap: onItemTapped,
      ),
    );
  }
}
