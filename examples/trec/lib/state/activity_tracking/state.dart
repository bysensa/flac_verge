import 'package:verge/verge.dart';

import 'tracking_status.dart';

class ActivityTrackingState extends State with ActivityTracking {
  ActivityTrackingState.initial() {
    trackingStatus = TrackingStatusState.initial();
  }

  @override
  State get newState => ActivityTrackingState.initial();
}

mixin ActivityTracking {
  late TrackingStatusState trackingStatus;
}
