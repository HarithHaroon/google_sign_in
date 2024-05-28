import 'package:appwrite/appwrite.dart';
import 'package:g_sign_in/src/providers/client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'db_provider.g.dart';

@riverpod
Databases db(DbRef ref) {
  final client = ref.read(clientProvider);
  return Databases(client);
}
