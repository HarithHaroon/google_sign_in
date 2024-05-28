import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:g_sign_in/src/providers/auth_provider.dart';
import 'package:g_sign_in/src/screens/home_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../widgets/login_button.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authProvider, (previous, next) {
      next.when(
        data: (authState) {
          switch (authState) {
            case Authenticated():
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const HomeScreen();
                  },
                ),
              );
            case Unauthenticated():
              return;
            case AuthError():
              return;
            case AuthLoading():
              return;
            case AuthSuccess():
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const HomeScreen();
                  },
                ),
              );
          }
        },
        error: (error, stackTrace) {},
        loading: () {},
      );
    });
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    useListenable(emailController);
    useListenable(passwordController);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'test@test.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            LoginButton(
              email: emailController.text,
              password: passwordController.text,
            ),
          ],
        ),
      ),
    );
  }
}
