import 'package:verge/verge.dart';

import 'state.dart';

class ApplicationStore extends Store<ApplicationState> {
  ApplicationStore() : super(ApplicationState.initial());
}
