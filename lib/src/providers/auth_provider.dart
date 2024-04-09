import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../shared/environment_variables.dart';
import 'auth_state.dart';
import 'google_sign_in_provider.dart';
import 'http_client_provider.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    return AuthInitial();
  }

  Future<void> signInWithGoogle() async {
    state = AuthLoading();

    final googleSignIn = ref.read(googleSignInProvider);

    final GoogleSignInAccount? account = await googleSignIn.signIn();

    if (account != null) {
      state = await _registerUserEmail(account.email);
    } else {
      state = AuthInitial();
    }
  }

  Future<AuthState> _registerUserEmail(String email) async {
    final client = ref.read(clientProvider);

    final uri = Uri.https(
      authority,
      usersPath,
    );

    final response = await client.post(
      uri,
      body: {
        'email': email,
      },
    );

    if (response.statusCode == HttpStatus.created) {
      return AuthSuccess();
    } else {
      return AuthError();
    }
  }
}
