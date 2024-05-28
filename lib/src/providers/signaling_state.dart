sealed class SignalingState {}

class Initial extends SignalingState {}

class OpenCameraAndMice extends SignalingState {}

class PeerConnectionCreated extends SignalingState {}

class LocalTracksAdded extends SignalingState {}

class GotAnswer extends SignalingState {
  final String type;

  GotAnswer({required this.type});
}

class OfferSent extends SignalingState {}

class AnswerEvent extends SignalingState {}

class AnswerUpdated extends SignalingState {}

class ListetningForAnswer extends SignalingState {}

class CallerCandidatesSent extends SignalingState {}

class CalleeCandidatesSent extends SignalingState {}

class RemoteDescriptionSet extends SignalingState {}

class LocalDescriptionSet extends SignalingState {}

class CalleeCandidatesAdded extends SignalingState {}

class CallerCandidatesAdded extends SignalingState {}

class OnAddRemoteStreamCalled extends SignalingState {}

class CalleeDescriptionsSet extends SignalingState {}

class CallerNotified extends SignalingState {}

class CandidateSent extends SignalingState {}

class CandidateRecieved extends SignalingState {}

class IceStateCalled extends SignalingState {
  final String message;

  IceStateCalled({required this.message});
}
