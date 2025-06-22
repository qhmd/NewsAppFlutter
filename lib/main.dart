import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:newsapp/presentation/screens/profile/profile.dart';

import 'package:newsapp/presentation/state/auth_providers.dart';
import 'package:newsapp/presentation/state/bookmark_providers.dart';
import 'package:newsapp/presentation/state/connection_providers.dart';
import 'package:newsapp/presentation/state/news_providers.dart';
import 'package:newsapp/presentation/state/pageindex_providers.dart';


import 'package:newsapp/core/theme/colors.dart';
import 'package:newsapp/presentation/screens/inbox.dart';
import 'package:provider/provider.dart';
import 'package:newsapp/presentation/screens/home_screen.dart'; // <- ini import biasa
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import './data/models/bookmark.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:overlay_support/overlay_support.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Wajib untuk async main
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  Hive.registerAdapter(BookmarkAdapter());
  await Hive.openBox('bookmarkBox');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(create: (_) => PageIndexProvider()),
      ],
      child: OverlaySupport(child: const MyApp()),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    final ConnectProv = context.read<ConnectionProvider>();
    if (!ConnectProv.isConnected) {
        context.read<BookmarkProvider>().loadFromLocal();
    } else {
      final AuthInfo = context.read<AuthProvider>();
      if (AuthInfo.isLoggedIn) {
        context.read<BookmarkProvider>().syncFromCloud(AuthInfo.user!.uid);
      }
    }
    // Pindahkan listener ke sini
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        try {
          context.read<AuthProvider>().setUser(user, context);
        } catch (e) {
          debugPrint("errormain");
        }
      } else {
        try {} catch (e) {
          context.read<AuthProvider>().clearUser();
        }
      }
      context.read<BookmarkProvider>().syncFromCloud(user!.uid);
      debugPrint("isi user ${user}");
    });
  }

  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lighColorScheme,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: blackColorScheme,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),
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
  final List<Widget> _pages = [HomeScreen(), Inbox(), Profile()];

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<PageIndexProvider>().currentIndex;

    void _onItemTapped(int index) {
      context.read<PageIndexProvider>().changePage(index);
    }

    final theme = Theme.of(context);
    return Scaffold(
      body: _pages[currentIndex],
      backgroundColor: theme.colorScheme.primaryContainer,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: theme.colorScheme.primaryContainer,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
