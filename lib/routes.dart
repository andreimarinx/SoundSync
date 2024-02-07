import 'package:soundsync/pages/dashboard.dart';
import 'package:soundsync/pages/home.dart';
import 'package:soundsync/pages/login.dart';

var appRoutes = {
  '/': (context) => const Home(),
  '/login': (context) => const Login(),
  '/dashboard': (context) => const Dashboard(
        title: 'SOUNDSYNC',
      ),
};
