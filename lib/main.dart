import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:newsapp/presentation/screens/inbox._page.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

// Core imports
import 'package:newsapp/core/theme/colors.dart';

// Data imports
import 'package:newsapp/data/models/bookmark.dart';

// Presentation imports
import 'package:newsapp/presentation/screens/home_screen.dart';
import 'package:newsapp/presentation/screens/profile/profile.dart';

// State providers
import 'package:newsapp/presentation/state/auth_providers.dart';
import 'package:newsapp/presentation/state/bookmark_providers.dart';
import 'package:newsapp/presentation/state/comment_providers.dart';
import 'package:newsapp/presentation/state/connection_providers.dart';
import 'package:newsapp/presentation/state/like_providers.dart';
import 'package:newsapp/presentation/state/news_providers.dart';
import 'package:newsapp/presentation/state/pageindex_providers.dart';
import 'package:newsapp/presentation/state/theme_provider.dart';

// Services
import 'package:newsapp/services/setupfcm.dart';
import 'package:newsapp/services/local_notif.dart';

// Firebase options
import 'firebase_options.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

@pragma('vm:entry-point') // WAJIB agar tidak dihapus saat optimisasi
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background Notif Eksekusi");

  final newsUrl = message.data['newsUrl'] ?? '';
  final commentId = message.data['commentUid'] ?? '';
  final data = {
    'title': message.notification?.title ?? '',
    'body': message.notification?.body ?? '',
    'newsUrl': newsUrl,
    'commentId': commentId,
    'timestamp': Timestamp.now(),
  };

  firestore
      .collection('notifications')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('history')
      .add(data);
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(BookmarkAdapter());
  await Hive.openBox('bookmarkBox');
  await setupFCM();

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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        try {
          if (user != null) {
            final userDoc = await firestore
                .collection('users')
                .doc(user.uid)
                .get();
            final userData = userDoc.data();
            authProvider.setUser(
              user: user,
              userData: userData,
              context: context,
            );
          } else {
            authProvider.clearUser();
          }
        } catch (e) {
          debugPrint('❌ Error in auth state change: $e');
        }
      });

      // Initialize notifications and FCM
      await LocalNotificationService().init();
    } catch (e) {
      debugPrint('❌ Error during startup: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'News App',
      navigatorKey:
          navigatorKey, // Global navigator key untuk notification navigation
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
      themeMode: themeProvider.themeMode,

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
    _pages = [HomeScreen(key: homeKey), InboxPage(), Profile()];
  }

  void _onItemTapped(int index) {
    final currentIndex = context.read<PageIndexProvider>().currentIndex;
    if (index == 0 && currentIndex == 0) {
      // Jika Home sudah aktif, refresh kategori yang sedang aktif
      homeKey.currentState?.refreshCurrentCategory();
    } else {
      context.read<PageIndexProvider>().changePage(index);
    }
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
