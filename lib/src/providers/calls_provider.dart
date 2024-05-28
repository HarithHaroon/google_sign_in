import 'dart:developer' show log;

import 'package:appwrite/appwrite.dart';
import 'package:g_sign_in/src/providers/db_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants.dart';
import 'secure_storage_provider.dart';

import 'real_time_provider.dart';

part 'calls_provider.g.dart';

sealed class TestState {}

class State1 extends TestState {}

@Riverpod(keepAlive: true)
class CallsNotifier extends _$CallsNotifier {
  @override
  TestState build() {
    ref.onDispose(() async {
      log('dispose of subscription');
    });
    return State1();
  }

  Future<void> test() async {
    final db = ref.read(dbProvider);

    try {} catch (e) {
      log('E -> $e');
    }
  }

  void triggerStackbar() {
    state = State1();
  }
}
