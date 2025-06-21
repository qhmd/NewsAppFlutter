import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newsapp/core/utils/AuthService.dart';
import 'package:sign_button/sign_button.dart';
import 'package:newsapp/presentation/state/AuthProviders.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.primaryContainer,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            child: Text("Yes, I Want Sign in"),
            onPressed: () {
              showModalBottomSheet<void>(
                backgroundColor: theme.colorScheme.onSecondaryContainer,
                context: context,
                builder: (BuildContext context) {
                  return SizedBox(
                    height: 400,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 20,
                                top: 20,
                              ),
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Icon(Icons.close, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'assets/images/newsapplogo.png',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text("Sign In For More Featured", style: TextStyle(fontSize:18, fontWeight: FontWeight.w600, color: theme.colorScheme.onPrimary)),
                              )
                              ,
                              SignInButton(
                                buttonType: theme.brightness == Brightness.light ? ButtonType.google :  ButtonType.googleDark,
                                buttonSize: ButtonSize.large,
                                onPressed: () async {
                                  User? user = await _authService.signInWithGoogle(context);
                                  if (user == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Google login gagal"),
                                      ),
                                    );
                                  } else {
                                    Provider.of<AuthProvider>(context, listen: false).setUser(user, context);
                                    Navigator.pop(context);

                                  }
                                },
                              ),
                              SizedBox(
                                height: 10,
                              )
                              ,
                              SignInButton(
                                buttonType: theme.brightness == Brightness.light ? ButtonType.facebook :  ButtonType.facebookDark,
                                buttonSize: ButtonSize.large,
                                onPressed: () async {
                                  User? user = await _authService
                                      .signInWithFacebook();
                                  if (user == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Facebook login gagal"),
                                      ),
                                    );
                                  } else {
                                    Provider.of<AuthProvider>(context, listen: false).setUser(user, context);
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: 15),
            child: Text("Sign in for Bookmark your favorite news and reading in offline mode", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold , color: theme.colorScheme.onPrimary),textAlign: TextAlign.center)
          )
        ],
      ),
    );
  }

}
