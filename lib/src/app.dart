import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Video Chat',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
