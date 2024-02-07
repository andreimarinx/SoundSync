import 'package:flutter/cupertino.dart';

import '../services/auth.dart';
import 'dashboard.dart';
import 'login.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading');
        } else if (snapshot.hasError) {
          return const Center(child: Text("error"));
        } else if (snapshot.hasData) {
          return const Dashboard(
            title: 'SOUNDSYNC',
          );
        } else {
          return const Login();
        }
      },
    );
  }
}
