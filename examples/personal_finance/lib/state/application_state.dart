import 'package:verge/verge.dart';

class ApplicationState extends State implements Application {
  ApplicationState.initial();

  @override
  State get newState => ApplicationState.initial();
}

mixin Application {}
