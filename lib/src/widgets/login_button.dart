import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/auth_provider.dart';

class LoginButton extends ConsumerWidget {
  const LoginButton({
    super.key,
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final notifier = ref.read(authProvider.notifier);

        await notifier.loginUser(email: email, password: password);
      },
      child: const Text('Login'),
    );
  }
}
