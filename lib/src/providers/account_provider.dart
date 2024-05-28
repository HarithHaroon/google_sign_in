import 'package:appwrite/appwrite.dart' show Account, Client;
import 'package:g_sign_in/src/providers/client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_provider.g.dart';

@riverpod
Account account(AccountRef ref) {
  final Client client = ref.read(clientProvider);
  return Account(client);
}
