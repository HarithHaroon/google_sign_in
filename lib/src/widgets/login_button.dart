import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import 'login_button_content.dart';

const loginButtonText = 'Sign in with Google';

const indicatorSize = 25.0;

class LoginButton extends ConsumerWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    const style = TextStyle(color: Colors.white);

    switch (authState) {
      case AuthInitial():
        return const LoginButtonContent(
          child: Text(
            loginButtonText,
            style: style,
          ),
        );
      case AuthLoading():
        return const LoginButtonContent(
          child: SizedBox(
            width: indicatorSize,
            height: indicatorSize,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeCap: StrokeCap.round,
              strokeWidth: 2.0,
            ),
          ),
        );
      case AuthError():
        return const LoginButtonContent(
          child: Text(
            loginButtonText,
            style: style,
          ),
        );
      case AuthSuccess():
        return const LoginButtonContent(
          child: Text(
            loginButtonText,
            style: style,
          ),
        );
    }
  }
}
