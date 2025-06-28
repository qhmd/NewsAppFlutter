import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:newsapp/core/utils/AuthService.dart';
import 'package:newsapp/data/models/bookmark.dart';
import 'package:newsapp/presentation/screens/profile/option/crud_profile_page.dart';
import 'package:newsapp/presentation/screens/profile/option/list_bookmark.dart';
import 'package:newsapp/presentation/state/auth_providers.dart';
import 'package:newsapp/presentation/state/bookmark_providers.dart';
import 'package:newsapp/presentation/state/like_providers.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class DataProfile extends StatelessWidget {
  final String uid;

  const DataProfile({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('User data not found'));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final username = userData['username'] ?? 'No Name';
        final photoURL = userData['photoURL'] ?? '';
        final email = userData['email'] ?? '';

        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                backgroundImage: (photoURL.isNotEmpty)
                    ? NetworkImage(photoURL)
                    : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
                radius: 50,
              ),
              const SizedBox(height: 10),
              Text(
                username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SettingsList(
                  physics: const NeverScrollableScrollPhysics(),
                  sections: [
                    SettingsSection(
                      tiles: <SettingsTile>[
                        SettingsTile.navigation(
                          leading: const Icon(Icons.person),
                          title: const Text('Profile'),
                          onPressed: (context) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CrudProfilePage(),
                              ),
                            );
                          },
                        ),
                        SettingsTile.navigation(
                          leading: const Icon(Icons.bookmark_border_outlined),
                          title: const Text('Bookmark'),
                          onPressed: (context) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ListBookmark(),
                              ),
                            );
                          },
                        ),
                        SettingsTile.navigation(
                          leading: const Icon(Icons.book),
                          title: const Text('Offline Reading'),
                          onPressed: (context) => debugPrint("Offline"),
                        ),
                        SettingsTile.navigation(
                          leading: const Icon(Icons.logout),
                          title: const Text('Logout'),
                          onPressed: (context) {
                            _dialogBuilder(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    final theme = Theme.of(context);
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.onSecondaryContainer,
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
