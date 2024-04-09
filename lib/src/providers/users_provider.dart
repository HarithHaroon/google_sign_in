import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/users_models.dart';
import '../shared/environment_variables.dart';
import 'http_client_provider.dart';

part 'users_provider.g.dart';

@riverpod
Future<List<UsersData>> users(UsersRef ref) async {
  final client = ref.read(clientProvider);

  final uri = Uri.https(
    authority,
    usersPath,
    {'page': '2'},
  );

  final response = await client.get(uri);

  final map = jsonDecode(response.body);
  final users = UsersModel.fromJson(map);
  return users.data;
}
