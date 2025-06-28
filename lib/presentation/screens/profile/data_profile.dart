import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:newsapp/core/utils/AuthService.dart';
import 'package:newsapp/data/models/bookmark.dart';
import 'package:newsapp/presentation/screens/profile/option/crud_profile_page.dart';
import 'package:newsapp/presentation/screens/profile/option/list_bookmark.dart';
import 'package:newsapp/presentation/state/auth_providers.dart';
import 'package:newsapp/presentation/state/bookmark_providers.dart';
import 'package:newsapp/presentation/state/comment_providers.dart';
import 'package:newsapp/presentation/state/like_providers.dart';
import 'package:newsapp/presentation/state/news_providers.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class DataProfile extends StatelessWidget {
  final String uid;

  const DataProfile({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
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

        // ...existing code...
        return SafeArea(
          child: ColoredBox(
            color: theme.colorScheme.primaryContainer,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 6, // 1 foto, 1 username, 4 ListTile
              separatorBuilder: (context, index) {
                // Hanya beri Divider antar ListTile, bukan setelah foto/username
                if (index == 1 || index == 2 || index == 3 || index == 4) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Divider(
                      color: theme.colorScheme.onPrimary,
                      height: 1,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    padding: EdgeInsets.only(bottom: 20),
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: BoxBorder.all(
                        width: 1,
                        color: theme.colorScheme.onPrimary,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
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
                    leading: Icon(
                      Icons.person,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      'Profil',
                      style: TextStyle(color: theme.colorScheme.onPrimary),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CrudProfilePage(),
                        ),
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
                  return ListTile(
                    leading: Icon(Icons.book, color: theme.colorScheme.primary),
                    title: Text(
                      'Toggle',
                      style: TextStyle(color: theme.colorScheme.onPrimary),
                    ),
                    onTap: () => debugPrint('Offline'),
                  );
                }
                if (index == 4) {
                  return ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
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
      },
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    final theme = Theme.of(context);
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.onSecondary,
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
