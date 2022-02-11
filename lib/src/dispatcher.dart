import 'state.dart';
import 'package:meta/meta.dart';

// -----------------------------------------------------------------------------
// Dispatcher
// -----------------------------------------------------------------------------
abstract class Dispatcher<T extends State> {
  final Store<T> _targetStore;

  @mustCallSuper
  const Dispatcher({
    required Store<T> targetStore,
  }) : _targetStore = targetStore;

  /// perform commit using [mutation] on [targetStore]
  Future<T> commit(StateMutation<T> mutation) {
    return _targetStore.commit(mutation);
  }

  /// perform send [activity] using [targetStore]
  void send(covariant Activity activity) {
    _targetStore.send(activity);
  }
}
