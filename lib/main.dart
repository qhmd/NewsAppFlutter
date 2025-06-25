import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

// Core imports
import 'package:newsapp/core/theme/colors.dart';

// Data imports
import 'package:newsapp/data/models/bookmark.dart';

// Presentation imports
import 'package:newsapp/presentation/screens/home_screen.dart';
import 'package:newsapp/presentation/screens/inbox.dart';
import 'package:newsapp/presentation/screens/profile/profile.dart';

// State providers
import 'package:newsapp/presentation/state/auth_providers.dart';
import 'package:newsapp/presentation/state/bookmark_providers.dart';
import 'package:newsapp/presentation/state/comment_providers.dart';
import 'package:newsapp/presentation/state/connection_providers.dart';
import 'package:newsapp/presentation/state/like_providers.dart';
import 'package:newsapp/presentation/state/news_providers.dart';
import 'package:newsapp/presentation/state/pageindex_providers.dart';

// Services
import 'package:newsapp/services/local_notif.dart';
import 'package:newsapp/services/setupfcm.dart';

// Firebase options
import 'firebase_options.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point') // WAJIB agar tidak dihapus saat optimisasi
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Inisialisasi Firebase jika diperlukan (saat app terminated)
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
  // Bisa tambahkan logika lain di sini (seperti menyimpan lokal, dll)
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(BookmarkAdapter());
  await Hive.openBox('bookmarkBox');

  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(create: (_) => PageIndexProvider()),
        ChangeNotifierProvider(create: (_) => LikeProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => MyAppState()),
      ],
      child: OverlaySupport(child: const MyApp()),
    );
  }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleStartup();
    });
  }

  Future<void> _handleStartup() async {
    try {
      final connectProvider = context.read<ConnectionProvider>();
      final bookmarkProvider = context.read<BookmarkProvider>();
      final authProvider = context.read<AuthProvider>();

      // Handle bookmark sync based on connection status
      if (!connectProvider.isConnected) {
        bookmarkProvider.loadFromLocal();
      } else {
        if (authProvider.isLoggedIn) {
          await bookmarkProvider.syncFromCloud(authProvider.user!.uid);
        }
      }

      // Setup Firebase Auth state listener
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        try {
          if (user != null) {
            authProvider.setUser(user, context);
          } else {
            authProvider.clearUser();
          }
        } catch (e) {
          debugPrint('❌ Error in auth state change: $e');
        }
      });

      // Initialize notifications and FCM
      await LocalNotificationService().init();
      await setupFCM();
    } catch (e) {
      debugPrint('❌ Error during startup: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
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
      home: const BottomNavigation(),
    );
  }
}

class MyAppState extends ChangeNotifier {
  WordPair _current = WordPair.random();

  WordPair get current => _current;

  void getNext() {
    _current = WordPair.random();
    notifyListeners();
  }
}

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [const HomeScreen(), const Inbox(), const Profile()];
  }

  void _onItemTapped(int index) {
    context.read<PageIndexProvider>().changePage(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = context.watch<PageIndexProvider>().currentIndex;

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _pages),
      backgroundColor: theme.colorScheme.primaryContainer,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
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
