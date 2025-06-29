import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:newsapp/presentation/state/theme_provider.dart';
import 'package:newsapp/services/AuthService.dart';
import 'package:newsapp/data/models/bookmark.dart';
import 'package:newsapp/presentation/screens/profile/option/crud_profile_page.dart';
import 'package:newsapp/presentation/screens/profile/option/list_bookmark.dart';
import 'package:newsapp/presentation/state/auth_providers.dart';
import 'package:newsapp/presentation/state/bookmark_providers.dart';
import 'package:newsapp/presentation/state/comment_providers.dart';
import 'package:newsapp/presentation/state/like_providers.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class DataProfile extends StatefulWidget {
  final String uid;

  const DataProfile({super.key, required this.uid});

  @override
  State<DataProfile> createState() => _DataProfileState();
}

class _DataProfileState extends State<DataProfile> {
  // isChecked harus mencerminkan status tema saat ini dari ThemeProvider
  // Ini akan diinisialisasi di initState
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentThemeMode = context.read<ThemeProvider>().themeMode;
      setState(() {
        isChecked = currentThemeMode == ThemeMode.dark;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authSnap = context.watch<AuthProvider>().firestoreUserData;
    // Dapatkan themeProvider untuk membaca tema saat ini
    final themeProvider = context.watch<ThemeProvider>();

    final username = authSnap?['username'] ?? 'No Name';
    final photoURL = authSnap?['photoURL'] ?? '';

    return SafeArea(
      child: ColoredBox(
        color: theme.colorScheme.primaryContainer,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 6,
          separatorBuilder: (context, index) {
            if (index == 1 || index == 2 || index == 3 || index == 4) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Divider(color: theme.colorScheme.onPrimary, height: 1),
              );
            }
            return const SizedBox.shrink();
          },
          itemBuilder: (context, index) {
            if (index == 0) {
              return Container(
                padding: const EdgeInsets.only(bottom: 20),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: theme.colorScheme.onPrimary,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: CircleAvatar(
                        backgroundImage: (photoURL.isNotEmpty)
                            ? NetworkImage(photoURL)
                            : const AssetImage(
                                    'assets/images/default_avatar.png',
                                  )
                                  as ImageProvider,
                        radius: 50,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (index == 1) {
              return ListTile(
                leading: Icon(Icons.person, color: theme.colorScheme.primary),
                title: Text(
                  'Profil',
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CrudProfilePage()),
                  );
                },
              );
            }
            if (index == 2) {
              return ListTile(
                leading: Icon(
                  Icons.bookmark_border,
                  color: theme.colorScheme.primary,
                ),
                title: Text(
                  'Bookmark',
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ListBookmark()),
                  );
                },
              );
            }
            if (index == 3) {
              // Ini adalah bagian Toggle Tema Anda
              return ListTile(
                leading: Icon(
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.primary,
                ), // Icon yang lebih sesuai
                title: Text(
                  'Change Mode', // Atau 'Mode Terang' tergantung logika
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
                trailing: Container(
                  width: 60,
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: themeProvider.themeMode == ThemeMode.dark
                        ? const Color.fromARGB(255, 255, 0, 0)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: InkWell(
                    onTap: () {
                      context.read<ThemeProvider>().toggleTheme();
                    },
                    child: Stack(
                      children: [
                        AnimatedAlign(
                          // Sesuaikan alignment berdasarkan themeMode dari ThemeProvider
                          alignment: themeProvider.themeMode == ThemeMode.dark
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          child: AnimatedContainer(
                            width: 22,
                            height: 22,
                            duration: Duration(milliseconds: 300),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ListTile onTap untuk toggle juga bisa digunakan, tapi biasanya
                // ketika ada trailing widget interaktif, onTap ListTile diabaikan
                // onTap: () => debugPrint('Toggle ListTile pressed'),
              );
            }
            if (index == 4) {
              return ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  'Logout',
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
                onTap: () => _dialogBuilder(context),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    final theme = Theme.of(context);
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.primaryContainer,
          title: Text(
            'You sure you want to logout ?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('No', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Yes, I Sure'),
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                await AuthService().signOut();
                authProvider.clearUser();
                Provider.of<BookmarkProvider>(context, listen: false).clear();
                Provider.of<CommentProvider>(context, listen: false).clear();
                Provider.of<LikeProvider>(context, listen: false).clear();
                final box = await Hive.openBox<Bookmark>('bookmarks');
                await box.clear();

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
