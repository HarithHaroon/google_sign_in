import 'package:appwrite/appwrite.dart';
import 'package:g_sign_in/src/constants.dart';
import 'package:g_sign_in/src/providers/account_provider.dart';
import 'package:g_sign_in/src/providers/client_provider.dart';
import 'package:g_sign_in/src/providers/db_provider.dart';
import 'package:g_sign_in/src/providers/http_client_provider.dart';
import 'package:g_sign_in/src/providers/secure_storage_provider.dart';
import 'package:g_sign_in/src/providers/uuid_provider.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dart:developer' show log;

part 'auth_provider.g.dart';

const name = Constants.userName;

sealed class AuthState {}

class Authenticated extends AuthState {}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

@Riverpod(keepAlive: false)
class Auth extends _$Auth {
  @override
  Future<AuthState> build() async {
    final authState = await _getAuthState();

    switch (authState) {
      case Authenticated():
        return Authenticated();
      case Unauthenticated():
        return Unauthenticated();
      case AuthError():
        return AuthError();
      case AuthLoading():
        return AuthLoading();
      case AuthSuccess():
        return AuthSuccess();
    }
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final account = ref.read(accountProvider);

    final session = await account.createEmailPasswordSession(
      email: email,
      password: password,
    );

    //todo catch PlatformException
    await _cacheUserId(session.userId);
    await _cacheUserName(session.clientName);
    await _cacheSessionId(session.$id);

    log('-> login success');
    state = AsyncData(AuthSuccess());
  }

  Future<void> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      state = const AsyncLoading();

      final db = ref.read(dbProvider);

      final uuid = ref.read(uuidProvider);

      final id = uuid.v4();

      final client = ref.read(clientProvider);

      final account = Account(client);

      final sessionId = await _getSessionId();

      log('sessionId -> $sessionId');

      if (sessionId != null) {
        await _deleteSessionId();
        await logout();
      }

      await account.create(
        userId: id,
        email: email,
        password: password,
        name: name,
      );

      await loginUser(
        email: email,
        password: password,
      );

      final doc = await db.createDocument(
        databaseId: Constants.database,
        collectionId: Constants.usersCollection,
        documentId: id,
        data: {
          'id': id,
          'name': name,
        },
      );

      state = AsyncData(AuthSuccess());

      log('doc -> ${doc.data.entries}');
    } catch (e, st) {
      log('exception -> $e');
      if (e.toString() == Constants.mfaErrorText) {
        log('exception ->');

        return;
      }
      state = AsyncError(e, st);
    }
  }

  Future<void> logout() async {
    final account = ref.read(accountProvider);

    await account.deleteSessions();
  }

  Future<String> getUserId() async {
    final storage = ref.read(secureStorageProvider);
    final userId = await storage.read(key: Constants.userId);

    return userId!;
  }

  Future<String?> _getSessionId() async {
    final storage = ref.read(secureStorageProvider);

    final sessionId = await storage.read(
      key: Constants.sessionIdKey,
    );

    return sessionId;
  }

  Future<void> _deleteSessionId() async {
    final storage = ref.read(secureStorageProvider);

    await storage.delete(
      key: Constants.sessionIdKey,
    );
  }

  Future<void> _cacheUserName(String clientName) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: name, value: clientName);
  }

  Future<void> _cacheUserId(String userId) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: Constants.userId, value: userId);
  }

  Future<void> _cacheSessionId(String sessionId) async {
    final storage = ref.read(secureStorageProvider);

    await storage.write(
      key: Constants.sessionIdKey,
      value: sessionId,
    );
  }

  Future<AuthState> _getAuthState() async {
    final storage = ref.read(secureStorageProvider);

    final id = await storage.read(key: Constants.userId);

    if (id == null) {
      return Unauthenticated();
    } else {
      return Authenticated();
    }
  }
}
