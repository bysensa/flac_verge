class TrackingStatusState {
  final TrackingStatus trackingStatus;
  final DateTime changedAt;

  const TrackingStatusState({
    required this.trackingStatus,
    required this.changedAt,
  });

  TrackingStatusState.initial()
      : this(changedAt: DateTime.now(), trackingStatus: TrackingStatus.unknown);

  TrackingStatusState.active()
      : this(changedAt: DateTime.now(), trackingStatus: TrackingStatus.active);

  TrackingStatusState.paused()
      : this(changedAt: DateTime.now(), trackingStatus: TrackingStatus.paused);

  TrackingStatusState.stopped()
      : this(changedAt: DateTime.now(), trackingStatus: TrackingStatus.stopped);

  TrackingStatusState start() => _performTransition(TrackingStatus.active);
  TrackingStatusState stop() => _performTransition(TrackingStatus.stopped);
  TrackingStatusState pause() => _performTransition(TrackingStatus.paused);
  TrackingStatusState resume() => _performTransition(TrackingStatus.active);

  TrackingStatusState changeTo(TrackingStatus newStatus) {
    return _performTransition(newStatus);
  }

  TrackingStatusState _performTransition(TrackingStatus nextStatus) {
    if (trackingStatus.isTransitionAllowedTo(nextStatus)) {
      return TrackingStatusState(
        trackingStatus: nextStatus,
        changedAt: DateTime.now(),
      );
    } else {
      return this;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackingStatusState &&
          runtimeType == other.runtimeType &&
          trackingStatus == other.trackingStatus &&
          changedAt == other.changedAt;

  @override
  int get hashCode => trackingStatus.hashCode ^ changedAt.hashCode;

  @override
  String toString() {
    return 'TrackingStatusState{trackingStatus: $trackingStatus, changedAt: $changedAt}';
  }
}

enum TrackingStatus {
  unknown,
  active,
  paused,
  stopped,
}

extension TrackingStatusExt on TrackingStatus {
  bool get isPaused => this == TrackingStatus.paused;
  bool get isStopped => this == TrackingStatus.stopped;
  bool get isActive => this == TrackingStatus.active;
  bool get isUnknown => this == TrackingStatus.unknown;

  bool isTransitionAllowedTo(TrackingStatus nextStatus) {
    if (isUnknown) {
      return true;
    }
    if (isStopped && nextStatus.isActive) {
      return true;
    }
    if (isActive && (nextStatus.isStopped || nextStatus.isPaused)) {
      return true;
    }
    if (isPaused && (nextStatus.isActive || nextStatus.isStopped)) {
      return true;
    }
    return false;
  }
}
