import 'package:appwrite/appwrite.dart';
import 'package:g_sign_in/src/constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client_provider.g.dart';

@riverpod
Client client(ClientRef ref) {
  final client = Client();

  client.setEndpoint(Constants.endPoint);

  client.setProject(Constants.projectId);

  return client;
}
