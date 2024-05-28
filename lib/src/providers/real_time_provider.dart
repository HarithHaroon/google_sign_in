import 'package:appwrite/appwrite.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'client_provider.dart';

part 'real_time_provider.g.dart';

@Riverpod(keepAlive: true)
Realtime realtime(RealtimeRef ref) {
  final client = ref.read(clientProvider);
  return Realtime(client);
}
