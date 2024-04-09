import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'google_sign_in_provider.g.dart';

@riverpod
GoogleSignIn googleSignIn(GoogleSignInRef ref) {
  const List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];

  return GoogleSignIn(
    scopes: scopes,
  );
}