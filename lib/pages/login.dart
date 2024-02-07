import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../services/auth.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Color(0xFFB030B0), Color(0xFF602080)]))),
        title: Text(
          'SOUNDSYNC',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        color: Color(0xFF10102D),
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              './lib/assets/large_icon.png',
              height: 120,
            ),
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  width: double.infinity,
                  child: LoginButton(
                      text: "Sign in with google",
                      icon: FontAwesomeIcons.google,
                      color: Color(0xFFB030B0),
                      loginMethod: AuthService().googleLogin),
                ),
                FutureBuilder<Object>(
                  future: SignInWithApple.isAvailable(),
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return SignInWithAppleButton(
                        onPressed: () {
                          AuthService().signInWithApple();
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final Function loginMethod;

  const LoginButton(
      {super.key,
      required this.text,
      required this.icon,
      required this.color,
      required this.loginMethod});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white, size: 20),
        style: TextButton.styleFrom(
            padding: const EdgeInsets.all(24), backgroundColor: color),
        onPressed: () => loginMethod(),
        label: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
