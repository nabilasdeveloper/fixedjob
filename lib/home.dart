import 'package:fixedjob/screens/favorite_screen.dart';
import 'package:fixedjob/screens/history_screen.dart';
import 'package:fixedjob/screens/home_screen.dart';
import 'package:fixedjob/screens/profile_screen.dart';
import 'package:fixedjob/screens/search_screen.dart';
import 'package:flutter/material.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    HomeContentScreen(),
    SearchScreen(),
    FavoriteScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined, color: Colors.black,), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.search, color: Colors.black), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border, color: Colors.black), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.history, color: Colors.black), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person_2_outlined, color: Colors.black), label: ""),
        ],
      ),
    );
  }
}

