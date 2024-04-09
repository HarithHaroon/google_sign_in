import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/users_provider.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    final size = MediaQuery.sizeOf(context);

    final width = size.width * 0.15;
    final radius = size.width * 0.02;

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: SafeArea(
        child: users.when(
          data: (users) {
            if (users.isEmpty) return const Text('No users!');

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      user.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    subtitle: Text(
                      user.email,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    trailing: SizedBox(
                      width: width,
                      height: width,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(radius),
                        child: Image.network(
                          user.avatar,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
          error: (error, stackTrace) {
            return Center(
              child: InkWell(
                onTap: () {
                  ref.invalidate(usersProvider);
                },
                child: const Text(
                  'Somthing went wrong, tap to try again!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ),
            );
          },
          loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
