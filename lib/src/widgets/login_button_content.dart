import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/auth_provider.dart';

class LoginButtonContent extends ConsumerWidget {
  const LoginButtonContent({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;

    return SizedBox(
      width: width * 0.4,
      child: ElevatedButton(
        onPressed: () async {
          await ref.read(authProvider.notifier).signInWithGoogle();
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blue),
        ),
        child: child,
      ),
    );
  }
}
