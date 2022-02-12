import 'dart:async';
import 'dart:io';

import 'package:verge/verge.dart';

import '../ticker.dart';

class TimerStore extends Store<TimerState> {
  final Ticker _ticker;
  StreamSubscription<int>? _tickerSubscription;
  StreamSubscription<FileSystemEvent>? _fileWatchSubscription;

  TimerStore({
    required Ticker ticker,
  })  : _ticker = ticker,
        super(TimerState()) {
    _fileWatchSubscription = File(
            '/Users/s-a-sen/Development/sandbox/verge/examples/timer/README.md')
        .watch()
        .listen(print);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    _fileWatchSubscription?.cancel();
    return super.close();
  }

  void start() {
    if (state.status != TimerStatus.initial) {
      return;
    }
    commit((state) {
      state.status = TimerStatus.inProgress;
      return state;
    }).then((state) {
      _tickerSubscription?.cancel();
      _tickerSubscription = _ticker.tick(ticks: state.duration).listen(_onTick);
    });
  }

  void pause() {
    if (state.status == TimerStatus.inProgress) {
      _tickerSubscription?.pause();
      commit((state) => state..status = TimerStatus.pause);
    }
  }

  void resume() {
    if (state.status == TimerStatus.pause) {
      _tickerSubscription?.resume();
      commit((state) => state..status = TimerStatus.inProgress);
    }
  }

  void reset() {
    _tickerSubscription?.cancel();
    commit((state) => state
      ..status = TimerStatus.initial
      ..duration = TimerState.defaultDuration);
  }

  void _onTick(int duration) {
    final nextStatus = duration == 0 ? TimerStatus.complete : state.status;
    commit((state) => state
      ..status = nextStatus
      ..duration = duration);
  }
}

class TimerState extends State implements Timer {
  static const defaultDuration = 60;

  TimerState() {
    initialize(() {
      status = TimerStatus.initial;
      duration = defaultDuration;
    });
  }

  @override
  State get newState => TimerState();
}

mixin Timer {
  late TimerStatus status;
  late int duration;
}

enum TimerStatus {
  initial,
  inProgress,
  pause,
  complete,
}
