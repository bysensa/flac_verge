import 'package:verge/verge.dart';

import 'application_state.dart';

class ApplicationStore extends Store<ApplicationState> {
  ApplicationStore() : super(ApplicationState.initial());
}
