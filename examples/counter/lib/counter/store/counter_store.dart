import 'package:bloc/bloc.dart';
import 'package:verge/verge.dart';

class CounterStore extends Store<CounterState> {
  CounterStore() : super(CounterState());

  /// Add 1 to the current state.
  void increment() {
    commit((state) => state..counter += 1);
  }

  /// Subtract 1 from the current state.
  void decrement() => commit((state) => state..counter -= 1);
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
