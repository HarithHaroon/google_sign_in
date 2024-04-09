import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../widgets/snackbar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/auth_state.dart';
import '../widgets/login_button.dart';
import 'users_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      authProvider,
      (previous, next) {
        switch (next) {
          case AuthInitial():
            return;
          case AuthLoading():
            return;
          case AuthSuccess():
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) {
                  return const UsersScreen();
                },
              ),
            );
          case AuthError():
            showSnackBar(
              context: context,
              text: 'Somthing went wrong, please try gain!',
              color: Colors.red,
            );
        }
      },
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: const SafeArea(
        child: Center(
          child: IntrinsicWidth(
            stepWidth: 100,
            child: LoginButton(),
          ),
        ),
      ),
    );
  }
}
