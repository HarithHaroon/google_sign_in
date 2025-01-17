import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'http_client_provider.g.dart';

@riverpod
http.Client client(ClientRef ref) {
  return http.Client();
}
