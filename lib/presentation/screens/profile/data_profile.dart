import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:newsapp/core/utils/AuthService.dart';
import 'package:newsapp/presentation/screens/profile/option/list_bookmark.dart';
import 'package:newsapp/presentation/state/auth_providers.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

// Define a stateless widget for the DataProfile
class DataProfile extends StatelessWidget {
  // Firebase User object to hold user details
  final User user;

  DataProfile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: 20),
          CircleAvatar(
            backgroundImage: user.photoURL != null && user.photoURL!.isNotEmpty
                ? NetworkImage(user.photoURL!)
                : AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
            radius: 40,
          ),
          SizedBox(height: 10),
          Text("Email: ${user.email}"),
          SizedBox(height: 20),
          // Expanded agar SettingsList bisa scroll jika panjang
          Expanded(
            child: SettingsList(
              physics: NeverScrollableScrollPhysics(),
              sections: [
                SettingsSection(
                  tiles: <SettingsTile>[
                    SettingsTile.navigation(
                      leading: Icon(Icons.person),
                      title: Text('Profile'),
                      onPressed: (context) => debugPrint("Profile"),
                    ),
                    SettingsTile.navigation(
                      leading: Icon(Icons.bookmark_border_outlined),
                      title: Text('Bookmark'),
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
                      leading: Icon(Icons.book),
                      title: Text('Offline Reading'),
                      onPressed: (context) => debugPrint("Offline"),
                    ),
                    SettingsTile.navigation(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
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
  }

  Future<void> _dialogBuilder(BuildContext context) {
    debugPrint("masuk disini");
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
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
