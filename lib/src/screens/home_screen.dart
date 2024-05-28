import 'package:flutter/material.dart';
import 'package:g_sign_in/src/providers/users_provider.dart';
import 'package:g_sign_in/src/screens/call_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);

    return Scaffold(
      body: users.when(
        data: (usersData) {
          return ListView.builder(
            itemCount: usersData.length,
            itemBuilder: (context, index) {
              final user = usersData[index];

              return ListTile(
                onTap: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return CallScreen(userId: user.id);
                      },
                    ),
                  );
                },
                leading: Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 30,
                  ),
                ),
                trailing: const Text('tap to call'),
              );
            },
          );
        },
        error: (error, stackTrace) {
          return ElevatedButton(
            onPressed: () async {
              ref.invalidate(usersProvider);
            },
            child: const Center(
              child: Text(
                'Error',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.blue,
                ),
              ),
            ),
          );
        },
        loading: () {
          return const Center(
            child: Text(
              'Loading..',
              style: TextStyle(
                fontSize: 30,
                color: Colors.blue,
              ),
            ),
          );
        },
      ),
    );
  }
}
