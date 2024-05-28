// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peer_connection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$peerConnectionHash() => r'5b87201bac9f5ca91f768b441e524d5e115be58e';

/// See also [PeerConnection].
@ProviderFor(PeerConnection)
final peerConnectionProvider =
    AsyncNotifierProvider<PeerConnection, RTCPeerConnection>.internal(
  PeerConnection.new,
  name: r'peerConnectionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$peerConnectionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PeerConnection = AsyncNotifier<RTCPeerConnection>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
