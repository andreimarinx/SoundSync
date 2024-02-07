import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:soundsync/pages/dashboard.dart';
import 'package:soundsync/pages/home.dart';
import 'package:soundsync/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Text('error');
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          print(snapshot.connectionState);
          return MediaQuery(
            data: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                .copyWith(boldText: false),
            child: MaterialApp(
              useInheritedMediaQuery: true,
              debugShowCheckedModeBanner: false,
              routes: appRoutes,
            ),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return CircularProgressIndicator();
      },
    );
  }
}
