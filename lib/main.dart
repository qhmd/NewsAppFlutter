
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:newsapp/core/providers/NewsProvider.dart';
import 'package:newsapp/core/theme/colors.dart';
import 'package:newsapp/ui/screens/inbox.dart';
import 'package:newsapp/ui/screens/profile.dart';
import 'package:provider/provider.dart';
import 'package:newsapp/ui/screens/home_screen.dart'; // <- ini import biasa


void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => NewsProvider())],
      child: const MyApp()
      )
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lighColorScheme
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: blackColorScheme,
        ),
        home: BottomNavigation(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
}

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});
  @override
  State<BottomNavigation> createState() => _BottomNavigation();
}

class _BottomNavigation extends State<BottomNavigation> {
  int _selectedState = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedState = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    final theme = Theme.of(context);
    switch (_selectedState) {
      case 0 : 
        page = HomeScreen();
        break;
      case 1 : 
        page = Inbox();
        break;
      case 2 : 
        page = Profile();
        break;
      default:
        throw UnimplementedError("Tidak ada widget di $_selectedState");
    }

    return Scaffold(
      body: page,
      backgroundColor: theme.colorScheme.primaryContainer,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedState,
        selectedItemColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.primaryContainer,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
