import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:developer' show log;

part 'peer_connection_provider.g.dart';

const Map<String, dynamic> _configuration = {
  'iceServers': [
    {
      'urls': [
        'stun:stun.dls.net:3478',
        'stun:stun.vozelia.com:3478',
        // 'stun:stun.l.google.com:19302',
        // 'stun:s2.taraba.net:3478',
        // 'stun:stun1.l.google.com:19302',
        // 'stun:stun2.l.google.com:19302',
      ]
    }
  ]
};

@Riverpod(keepAlive: true)
class PeerConnection extends _$PeerConnection {
  @override
  Future<RTCPeerConnection> build() async {
    final RTCPeerConnection peerConnection = await createPeerConnection(
      _configuration,
    );

    peerConnection.onAddTrack = (stream, track) {
      log('-> track added');
    };

    peerConnection.onAddStream = (stream) {
      log('onAddStream-> ');
    };

    peerConnection.onIceCandidate = (RTCIceCandidate candidate) async {
      // log('Got candidate map in provider: -> ${candidate.toMap()}');
      // log('Got candidate: -> ${candidate}');
    };

    ref.onDispose(() {
      log('dispose peer connection ->');
      peerConnection.close();
    });

    return peerConnection;
  }

  Future<void> addTrack(MediaStreamTrack track, MediaStream stream) async {
    final peerConnection = state.requireValue;

    await peerConnection.addTrack(track, stream);

    state = AsyncData(peerConnection);
  }
}
