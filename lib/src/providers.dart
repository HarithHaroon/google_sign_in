import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
RTCVideoRenderer videoRenderer(VideoRendererRef ref) {
  final localVideo = RTCVideoRenderer();
  final remoteVideo = RTCVideoRenderer();
  MediaStream? localStream;

  ref.onAddListener(() async {
    await localVideo.initialize();
    await remoteVideo.initialize();

    final stream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': true,
    });

    localVideo.srcObject = stream;
    localStream = stream;

    remoteVideo.srcObject = await createLocalMediaStream('key');
  });

  ref.onDispose(() {
    localVideo.dispose();
    remoteVideo.dispose();
  });

  return localVideo;
}
