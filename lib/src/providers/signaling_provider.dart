import 'dart:async';
import 'dart:developer' show log;

import 'package:appwrite/appwrite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:g_sign_in/src/providers/real_time_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants.dart';
import 'db_provider.dart';

import 'signaling_state.dart';
import 'uuid_provider.dart';

part 'signaling_provider.g.dart';

typedef StreamStateCallback = void Function(MediaStream stream);

const Map<String, dynamic> _configuration = {
  'iceServers': [
    {'url': 'stun:stun1.l.google.com:19302'},
    {
      'url': 'turn:numb.viagenie.ca',
      'credential': 'muazkh',
      'username': 'webrtc@live.com',
    },
  ]
};

Map<String, dynamic> _voiceConstraints = {
  "mandatory": {
    "OfferToReceiveAudio": true,
    "OfferToReceiveVideo": true,
  },
  "optional": [],
};

RTCPeerConnection? _peerConnection;
MediaStream? _localStream;
MediaStream? _remoteStream;

@riverpod
class Signaling extends _$Signaling {
  StreamStateCallback? onAddRemoteStream;

  @override
  SignalingState build() {
    return Initial();
  }

  Future<void> openUserMedia(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    final MediaStream stream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': true,
    });

    localVideo.srcObject = stream;
    _localStream = stream;

    remoteVideo.srcObject = await createLocalMediaStream('key');

    state = OpenCameraAndMice();
  }

  bool _isFirstIceCandidate = true;

  Future<String> createRoom({
    required String userId,
    required String roomId,
  }) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('rooms').doc();

    _peerConnection = await createPeerConnection(_configuration);

    state = PeerConnectionCreated();

    setOnAddStreamListener();

    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    state = LocalTracksAdded();

    iceState();

    // Code for collecting ICE candidates below
    var callerCandidatesCollection = roomRef.collection('callerCandidates');

    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('Got candidate: ${candidate.toMap()}');
      callerCandidatesCollection.add(candidate.toMap());
      state = CandidateSent();
    };
    // Finish Code for collecting ICE candidate

    // Add code for creating a room
    RTCSessionDescription offer = await _peerConnection!.createOffer();

    await _peerConnection!.setLocalDescription(offer);

    state = LocalDescriptionSet();
    print('Created offer: $offer');

    Map<String, dynamic> roomWithOffer = {'offer': offer.toMap()};

    await roomRef.set(roomWithOffer);

    state = OfferSent();

    //! room id
    final String roomId = roomRef.id;

    print('New room created with SDK offer. Room ID: $roomId');

    // Created a Room

    _peerConnection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream $track');
        _remoteStream?.addTrack(track);
      });
    };

    // Listening for remote session description below
    roomRef.snapshots().listen((snapshot) async {
      print('Got updated room: ${snapshot.data()}');
      state = GotAnswer(type: 'answer');

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (_peerConnection?.getRemoteDescription() != null &&
          data['answer'] != null) {
        var answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );

        print("Someone tried to connect");
        await _peerConnection?.setRemoteDescription(answer);
        state = RemoteDescriptionSet();
      }
    });
    // Listening for remote session description above

    // Listen for remote Ice candidates below
    roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          // print('Got new remote ICE candidate: ${jsonEncode(data)}');
          _peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
          state = CandidateRecieved();
        }
      });
    });
    // Listen for remote ICE candidates above

    return roomId;
  }

  Future<void> joinRoom({
    required String roomId,
  }) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    print(roomId);
    DocumentReference roomRef = db.collection('rooms').doc(roomId);
    var roomSnapshot = await roomRef.get();
    print('Got room ${roomSnapshot.exists}');

    if (roomSnapshot.exists) {
      _peerConnection = await createPeerConnection(_configuration);

      state = PeerConnectionCreated();

      setOnAddStreamListener();

      _localStream?.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, _localStream!);
      });

      state = LocalTracksAdded();

      iceState();

      // Code for collecting ICE candidates below
      var calleeCandidatesCollection = roomRef.collection('calleeCandidates');
      _peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
        if (candidate == null) {
          print('onIceCandidate: complete!');
          return;
        }
        print('onIceCandidate: ${candidate.toMap()}');
        calleeCandidatesCollection.add(candidate.toMap());
        state = CandidateSent();
      };
      // Code for collecting ICE candidate above

      _peerConnection?.onTrack = (RTCTrackEvent event) {
        print('Got remote track: ${event.streams[0]}');
        event.streams[0].getTracks().forEach((track) {
          print('Add a track to the remoteStream: $track');
          _remoteStream?.addTrack(track);
        });
      };

      // Code for creating SDP answer below
      var data = roomSnapshot.data() as Map<String, dynamic>;
      print('Got offer $data');
      var offer = data['offer'];
      await _peerConnection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );

      state = RemoteDescriptionSet();

      var answer = await _peerConnection!.createAnswer();
      print('Created Answer $answer');

      await _peerConnection!.setLocalDescription(answer);

      state = LocalDescriptionSet();

      Map<String, dynamic> roomWithAnswer = {
        'answer': {'type': answer.type, 'sdp': answer.sdp}
      };

      await roomRef.update(roomWithAnswer);

      state = AnswerUpdated();

      // Finished creating SDP answer

      // Listening for remote ICE candidates below
      roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((document) {
          var data = document.doc.data() as Map<String, dynamic>;
          print(data);
          print('Got new remote ICE candidate: $data');
          _peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
          state = CandidateRecieved();
        });
      });
    }
  }

  Future<void> setOfferAsRemoteDescription({
    required RTCSessionDescription offer,
  }) async {
    await _peerConnection?.setRemoteDescription(
      RTCSessionDescription(offer.sdp, offer.type),
    );
    log('-> setRemoteDescription success');
    state = RemoteDescriptionSet();
  }

  Future<RTCSessionDescription> createAnswer() async {
    final answer = await _peerConnection!.createAnswer(_voiceConstraints);

    return answer;
  }

  Future<RTCSessionDescription> createOffer() async {
    final RTCSessionDescription offer =
        await _peerConnection!.createOffer(_voiceConstraints);

    return offer;
  }

  Future<void> sendOfferToDatabase({
    required RTCSessionDescription offer,
    required String roomId,
  }) async {
    final db = ref.read(dbProvider);

    await db.createDocument(
      databaseId: Constants.database,
      collectionId: Constants.offersCollection,
      documentId: roomId,
      data: {
        'sdp': offer.sdp,
        'type': offer.type,
      },
    );
    state = OfferSent();
  }

  Future<String> saveCallerIceCandidateToDatabase({
    required RTCIceCandidate candidate,
    required String roomId,
  }) async {
    final uuid = ref.read(uuidProvider);
    final db = ref.read(dbProvider);

    final String id = uuid.v4();

    try {
      await db.createDocument(
        databaseId: Constants.database,
        collectionId: Constants.callerCandidates,
        documentId: id,
        data: {
          'candidate': candidate.candidate,
          'sdpMLineIndex': candidate.sdpMLineIndex,
          'sdpMid': candidate.sdpMid,
        },
      );

      // log('-> created doc with id $id');
    } catch (e) {
      log('E on ice gathering-> $e $id');
    }

    return id;
  }

  Future<void> createEmptyDocuments({
    required String roomId,
  }) async {
    try {
      final db = ref.read(dbProvider);

      // create an empty answer document
      await db.createDocument(
        databaseId: Constants.database,
        collectionId: Constants.answersCollection,
        documentId: roomId,
        data: {
          'sdp': '',
          'type': '',
        },
      );

      // log('3-> done create an empty answer document');

      // create an empty caller room document to save ice candidates documents IDs related to the caller related to this room
      await db.createDocument(
        databaseId: Constants.database,
        collectionId: Constants.callersCandidatesIDs,
        documentId: roomId,
        data: {
          'callerCandidatesIDs': [],
        },
      );

      // log('4-> done create an empty caller room document');

      // create an empty callee room document to save ice candidates documents related to the callee related to this room
      await db.createDocument(
        databaseId: Constants.database,
        collectionId: Constants.calleesCandidatesIDs,
        documentId: roomId,
        data: {
          'calleeCandidatesIDs': [],
        },
      );
      // log('5-> done create an empty callee room document');

      await db.createDocument(
        databaseId: Constants.database,
        collectionId: Constants.calleesDescriptions,
        documentId: roomId,
        data: {
          'descriptionsSet': false,
        },
      );
    } catch (e) {
      log('step1-> $e');
    }
  }

  Future<String> sendCalleeIceCandidatesToDatabase({
    required RTCIceCandidate candidate,
    required String roomId,
  }) async {
    final db = ref.read(dbProvider);
    final uuid = ref.read(uuidProvider);
    final String id = uuid.v4();
    try {
      await db.createDocument(
        databaseId: Constants.database,
        collectionId: Constants.calleeCandidates,
        documentId: id,
        data: {
          'candidate': candidate.candidate,
          'sdpMLineIndex': candidate.sdpMLineIndex,
          'sdpMid': candidate.sdpMid,
        },
      );

      // log('-> created callee doc success');
    } catch (e) {
      log('E-> sebdCalleeIceCandidatesInDatabase$e');
    }

    return id;
  }

  void addLocalStreamTracksToPeerConnection() {
    log('-> start adding tracks to localStream');
    final tracks = _localStream?.getTracks() ?? [];

    for (final MediaStreamTrack track in tracks) {
      _peerConnection?.addTrack(track, _localStream!);
    }
    log('-> end adding tracks to localStream');
    state = LocalTracksAdded();
  }

  Future<void> setOfferAsLocalDescription(RTCSessionDescription offer) async {
    await _peerConnection?.setLocalDescription(offer);
    state = LocalDescriptionSet();
  }

  Future<void> getCallerIceCandidatesAndSendThemToDatabase(
    String roomId,
  ) async {
    List<RTCIceCandidate> candidates = [];

    _peerConnection?.onIceCandidate = (RTCIceCandidate? candidate) async {
      if (candidate != null) {
        candidates.add(candidate);

        if (_isFirstIceCandidate) {
          _isFirstIceCandidate = false;

          await createEmptyDocuments(
            roomId: roomId,
          ).whenComplete(() async {
            List<String> ids = [];

            for (var candidate in candidates) {
              final String id = await saveCallerIceCandidateToDatabase(
                candidate: candidate,
                roomId: roomId,
              );
              ids.add(id);
            }

            await updateCallerIDsList(ids: ids, roomId: roomId);
            state = CallerCandidatesSent();
          });
        }
      }
    };
  }

  //todo remove
  void iceState() {
    _peerConnection?.onIceConnectionState = (RTCIceConnectionState iceState) {
      log('ice state->  $iceState ');
      state = IceStateCalled(message: '$iceState');
    };
    _peerConnection?.onRenegotiationNeeded = () {
      log('->  onRenegotiationNeededonRenegotiationNeeded ');
    };
  }

  void setOnAddStreamListener() {
    log('-> setOnAddStreamListener');

    _peerConnection?.onAddStream = (MediaStream stream) {
      log('-> onAddStream is called');
      onAddRemoteStream?.call(stream);
      _remoteStream = stream;
      state = OnAddRemoteStreamCalled();
    };
  }

  void setOnTrackListener() {
    log('-> setOnTrackListener');

    _peerConnection?.onTrack = (RTCTrackEvent event) {
      log('-> setOnTrackListener called');

      event.streams[0].getTracks().forEach((track) {
        _remoteStream?.addTrack(track);
      });
    };
  }

  void listenForAnswerAndSetRemoteDescription(String roomId) {
    final realTime = ref.read(realtimeProvider);

    final subscription = realTime.subscribe(
      ['databases.webrtc.collections.answers.documents.$roomId'],
    );

    state = ListetningForAnswer();

    subscription.stream.listen((RealtimeMessage event) async {
      log('-> answer event');
      state = AnswerEvent();
      final sdp = event.payload['sdp'] as String;
      final type = event.payload['type'] as String;

      if (sdp.isNotEmpty && type.isNotEmpty) {
        state = GotAnswer(type: '-> $type');
        final answer = RTCSessionDescription(sdp, type);

        await _peerConnection?.setRemoteDescription(answer);
        state = RemoteDescriptionSet();
        log('-> setRemoteDescription(answer)  success');
        await subscription.close();
      }
    });
  }

  void listenForCalleeIceCandidatesAndAddThemToPeerConnection(
    String roomId,
  ) {
    final realTime = ref.read(realtimeProvider);
    final db = ref.read(dbProvider);

    final subscription = realTime.subscribe(
      [
        'databases.webrtc.collections.${Constants.calleesCandidatesIDs}.documents.$roomId'
      ],
    );

    subscription.stream.listen((RealtimeMessage event) async {
      // log('-> callee candidate event');
      final calleeIceDone = event.payload['calleeIceDone'] as bool;

      if (calleeIceDone) {
        final doc = await db.getDocument(
          databaseId: Constants.database,
          collectionId: Constants.calleesCandidatesIDs,
          documentId: roomId,
        );

        List<String> ids = [];

        final data = doc.data['calleeCandidatesIDs'] as List<dynamic>;

        for (final id in data) {
          ids.add(id);
        }

        for (final id in ids) {
          final doc = await db.getDocument(
            databaseId: Constants.database,
            collectionId: Constants.calleeCandidates,
            documentId: id,
          );

          final candidate = doc.data['candidate'];
          final sdpMid = doc.data['sdpMid'];
          final sdpMLineIndex = doc.data['sdpMLineIndex'];

          _peerConnection?.addCandidate(
            RTCIceCandidate(
              candidate,
              sdpMid,
              sdpMLineIndex,
            ),
          );
        }

        state = CalleeCandidatesAdded();
      }
    });
    log('-> done listening for callee candidates');
  }

  Future<void> updateCallerIceDone(String roomId) async {
    final db = ref.read(dbProvider);

    _peerConnection?.onIceGatheringState = (state) async {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
        log('-> finally update callerIceDone');

        try {
          await db.updateDocument(
            databaseId: Constants.database,
            collectionId: Constants.callersCandidatesIDs,
            documentId: roomId,
            data: {
              'callerIceDone': true,
            },
          );
          log('-> you can answer the call');
        } catch (e) {
          log('callerIceDone Exception-> $e');
        }
      }
    };
  }

  Future<void> updateCallerIDsList({
    required List<String> ids,
    required String roomId,
  }) async {
    try {
      final db = ref.read(dbProvider);
      await db.updateDocument(
        databaseId: Constants.database,
        collectionId: Constants.callersCandidatesIDs,
        documentId: roomId,
        data: {
          'callerCandidatesIDs': ids,
        },
      );
      log('-> adding candidate id to list');
    } catch (e) {
      log('updateCallerIDsList Exception-> $e');
    }
  }

  Future<RTCSessionDescription> getOffer(String roomId) async {
    final db = ref.read(dbProvider);

    final doc = await db.getDocument(
      databaseId: Constants.database,
      collectionId: Constants.offersCollection,
      documentId: roomId,
    );

    final sdp = doc.data['sdp'] as String;
    final type = doc.data['type'] as String;

    return RTCSessionDescription(sdp, type);
  }

  Future<void> updateAnswerInDatabase({
    required RTCSessionDescription answer,
    required String roomId,
  }) async {
    try {
      final db = ref.read(dbProvider);
      await db.updateDocument(
        databaseId: Constants.database,
        collectionId: Constants.answersCollection,
        documentId: roomId,
        data: {
          'sdp': answer.sdp,
          'type': answer.type,
        },
      );

      log('-> updated answer doc success');
      state = AnswerUpdated();
    } catch (e) {
      log('E -> updated answer $e');
    }
  }

  Future<void> setAnswerAsLocalDescription(RTCSessionDescription answer) async {
    await _peerConnection?.setLocalDescription(answer);
    state = LocalDescriptionSet();

    //! firebase send calleeCandidates
    _peerConnection?.onIceCandidate = (RTCIceCandidate? candidate) async {
      if (candidate != null) {
        final collection =
            FirebaseFirestore.instance.collection('calleeCandidates');

        await collection.add({
          'candidate': candidate.candidate,
          'sdpMLineIndex': candidate.sdpMLineIndex,
          'sdpMid': candidate.sdpMid,
        });

        state = CandidateSent();
      }
    };
  }

  Future<void> getCalleeIceCandidatesAndSendThemToDatabase(
    String roomId,
  ) async {
    List<RTCIceCandidate> candidates = [];

    Timer timer = Timer(
      const Duration(seconds: 1),
      () async {},
    );

    Future<void> callback() async {
      List<String> ids = [];
      for (var candidate in candidates) {
        final id = await sendCalleeIceCandidatesToDatabase(
          candidate: candidate,
          roomId: roomId,
        );

        ids.add(id);
      }

      await updateCalleeCandidatesIDs(ids: ids, roomId: roomId);
      state = CalleeCandidatesSent();
    }

    _peerConnection?.onIceCandidate = (RTCIceCandidate? candidate) async {
      // log('->  candidate listener ');

      if (candidate != null) {
        candidates.add(candidate);

        timer.cancel();
        timer = Timer(const Duration(seconds: 1), callback);
      }
    };
  }

  Future<void> updateCalleeCandidatesIDs({
    required List<String> ids,
    required String roomId,
  }) async {
    final db = ref.read(dbProvider);

    await db.updateDocument(
      databaseId: Constants.database,
      collectionId: Constants.calleesCandidatesIDs,
      documentId: roomId,
      data: {
        'calleeCandidatesIDs': ids,
        'calleeIceDone': true,
      },
    );

    log('-> final update success');
  }

  Future<void> getCallerICeCandidatesFromDatabaseAddThemToPeerConnection(
    String roomId,
  ) async {
    final db = ref.read(dbProvider);

    final doc = await db.getDocument(
      databaseId: Constants.database,
      collectionId: Constants.callersCandidatesIDs,
      documentId: roomId,
    );

    List<String> ids = [];

    final data = doc.data['callerCandidatesIDs'] as List<dynamic>;

    for (var id in data) {
      ids.add(id);
    }

    for (var id in ids) {
      final doc = await db.getDocument(
        databaseId: Constants.database,
        collectionId: Constants.callerCandidates,
        documentId: id,
      );

      final candidate = doc.data['candidate'];
      final sdpMid = doc.data['sdpMid'];
      final sdpMLineIndex = doc.data['sdpMLineIndex'];

      _peerConnection?.addCandidate(
        RTCIceCandidate(
          candidate,
          sdpMid,
          sdpMLineIndex,
        ),
      );
    }
    state = CallerCandidatesAdded();
  }
}
