import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants.dart';
import 'auth_provider.dart';
import 'db_provider.dart';
import 'user.dart';

part 'users_provider.g.dart';

@Riverpod(keepAlive: true)
class Users extends _$Users {
  @override
  Future<List<UserData>> build() async {
    final List<UserData> users = [];

    final authNotifier = ref.read(authProvider.notifier);

    final db = ref.read(dbProvider);

    final usersDocuments = await db.listDocuments(
      databaseId: Constants.database,
      collectionId: Constants.usersCollection,
    );

    final userId = await authNotifier.getUserId();

    for (final user in usersDocuments.documents) {
      if (user.$id != userId) {
        users.add(
          UserData(
            id: user.$id,
            name: user.data['name'] ?? '',
          ),
        );
      }
    }

    return users;
  }
}
