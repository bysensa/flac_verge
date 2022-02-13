import 'package:trec/state/activity_tracking/state.dart';
import 'package:verge/verge.dart';

class ApplicationState extends State implements Application {
  ApplicationState.initial() {
    activityTracking = ActivityTrackingState.initial();
  }

  @override
  State get newState => ApplicationState.initial();
}

mixin Application {
  late ActivityTrackingState activityTracking;
}
