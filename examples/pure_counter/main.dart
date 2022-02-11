import 'package:bloc/bloc.dart';
import 'package:verge/verge.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('onCreate -- bloc: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('onEvent -- bloc: ${bloc.runtimeType}, event: $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('onChange -- bloc: ${bloc.runtimeType}, change: $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('onTransition -- bloc: ${bloc.runtimeType}, transition: $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('onError -- bloc: ${bloc.runtimeType}, error: $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('onClose -- bloc: ${bloc.runtimeType}');
  }
}

void main() {
  BlocOverrides.runZoned(() {
    vergeVain();
  }, blocObserver: SimpleBlocObserver());
}

void vergeVain() {
  print('----------VERGE----------');

  /// Create a `CounterCubit` instance.
  final store = CounterStore();

  /// Access the state of the `cubit` via `state`.
  print(store.state.counter); // 0

  /// Interact with the `cubit` to trigger `state` changes.
  store.increment();

  /// Access the new `state`.
  print(store.state.counter); // 1

  /// Close the `cubit` when it is no longer needed.
  store.close();
}

class CounterStore extends Store<CounterState> {
  CounterStore() : super(CounterState());

  void increment() {
    commit((state) {
      state.counter += 1;
      return state;
    });
  }
}

class CounterState extends State implements Counter {
  CounterState() {
    initialize(() {
      counter = 0;
    });
  }

  @override
  State get newState => CounterState();
}

mixin Counter {
  late int counter;
}
