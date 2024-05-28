import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:g_sign_in/src/providers/signaling_state.dart';
import 'package:g_sign_in/src/widgets/snackbar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/signaling_provider.dart';
import '../widgets/renderer_container.dart';

class CallScreen extends StatefulHookConsumerWidget {
  const CallScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CallsScreenState();
}

class _CallsScreenState extends ConsumerState<CallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();

    _localRenderer.initialize();
    _remoteRenderer.initialize();

    final notifier = ref.read(signalingProvider.notifier);

    notifier.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      signalingProvider,
      (previous, next) {
        switch (next) {
          case Initial():
            showSnackBar(context: context, text: 'Initial');
            return;
          case OpenCameraAndMice():
            showSnackBar(context: context, text: 'OpenCameraAndMice');
            return;
          case PeerConnectionCreated():
            showSnackBar(context: context, text: 'PeerConnectionCreated');
            return;
          case LocalTracksAdded():
            showSnackBar(context: context, text: 'LocalTracksAdded');
            return;
          case GotAnswer():
            showSnackBar(context: context, text: 'GotAnswer -> ${next.type}');
            return;
          case AnswerUpdated():
            showSnackBar(context: context, text: 'AnswerUpdated');
            return;
          case CallerCandidatesSent():
            showSnackBar(context: context, text: 'CallerCandidatesSent');
            return;
          case CalleeCandidatesSent():
            showSnackBar(context: context, text: 'CalleeCandidatesSent');
            return;
          case RemoteDescriptionSet():
            showSnackBar(context: context, text: 'RemoteDescriptionSet');
            return;
          case LocalDescriptionSet():
            showSnackBar(context: context, text: 'LocalDescriptionSet');
            return;
          case CalleeCandidatesAdded():
            showSnackBar(context: context, text: 'CalleeCandidatesAdded');
            return;
          case CallerCandidatesAdded():
            showSnackBar(context: context, text: 'CallerCandidatesAdded');
            return;
          case OnAddRemoteStreamCalled():
            showSnackBar(context: context, text: 'OnAddRemoteStreamCalled');
            return;
          case IceStateCalled():
            showSnackBar(
              context: context,
              text: 'IceStateCalled ${next.message}',
            );
            return;
          case AnswerEvent():
            showSnackBar(
              context: context,
              text: 'AnswerEvent',
            );
            return;
          case OfferSent():
            showSnackBar(
              context: context,
              text: 'OfferSent',
            );
            return;
          case ListetningForAnswer():
            showSnackBar(
              context: context,
              text: 'ListetningForAnswer',
            );
            return;
          case CalleeDescriptionsSet():
            showSnackBar(
              context: context,
              text: 'CaleeDescriptionsSet',
            );
            return;
          case CallerNotified():
            showSnackBar(
              context: context,
              text: 'CallerNotified',
            );
            return;
          case CandidateSent():
            showSnackBar(
              context: context,
              text: 'CandidateSent',
            );
            return;
          case CandidateRecieved():
            showSnackBar(
              context: context,
              text: 'CandidateRecieved',
            );
            return;
        }
      },
    );

    //! restore later
    // ref.watch(signalingProvider);

    final idController = useTextEditingController();

    useListenable(idController);

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                RendererContainer(
                  child: RTCVideoView(
                    _localRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    mirror: true,
                  ),
                ),
                const SizedBox(height: 5),
                RendererContainer(
                  child: RTCVideoView(
                    _remoteRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final notifier = ref.read(signalingProvider.notifier);

                    await notifier.openUserMedia(
                      _localRenderer,
                      _remoteRenderer,
                    );
                    //! remove later
                    setState(() {});
                  },
                  child: const Text('Open camera & microphone'),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: TextFormField(
                    controller: idController,
                    decoration: InputDecoration(
                      hintText: 'room id',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final signalNotifier = ref.read(
                          signalingProvider.notifier,
                        );

                        idController.text = await signalNotifier.createRoom(
                          userId: widget.userId,
                          roomId: idController.text,
                        );
                        //! remove later
                        setState(() {});
                      },
                      child: const Text('Call'),
                    ),
                    const SizedBox(width: 50),
                    ElevatedButton(
                      onPressed: () async {
                        final signalNotifier = ref.read(
                          signalingProvider.notifier,
                        );

                        await signalNotifier.joinRoom(
                          roomId: idController.text,
                        );
                      },
                      child: const Text('Answer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
