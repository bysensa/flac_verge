import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

// -----------------------------------------------------------------------------
// Typedefs
// -----------------------------------------------------------------------------

typedef VoidCallback = void Function();

// -----------------------------------------------------------------------------
// Symbol Extension
// -----------------------------------------------------------------------------
final symbolNameRegExp = RegExp(r'Symbol\("([a-zA-Z0-9_$]*)[=]?"\)');

extension SymbolExt on Symbol {
  String? get name {
    final symbolAsString = toString();
    return symbolNameRegExp.firstMatch(symbolAsString)?[1];
  }
}

// -----------------------------------------------------------------------------
// Verge Error
// -----------------------------------------------------------------------------

class VergeError extends StateError {
  VergeError(String message) : super(message);
}

// -----------------------------------------------------------------------------
// State
// -----------------------------------------------------------------------------
class State {
  static final _stateEquality = DeepStateEquality();

  Map<String, dynamic> _readState = {};
  Map<String, dynamic>? _writeState;
  Set<String> _visitedPaths = {};

  State get newState;

  bool get isModified => _writeState != null;
  bool get isNotModified => !isModified;
  bool get isVisited => _visitedPaths.isNotEmpty;

  // -----------------------------------------------------------------------------
  // Initialization
  // -----------------------------------------------------------------------------
  bool _initialized = false;
  void initialize(VoidCallback initialize) {
    if (_initialized) {
      return;
    }
    try {
      runZoned(() {
        initialize();
      }, zoneValues: {_CommitContext: const _CommitContext()});
    } on Exception catch (err, trace) {
      Zone.current.handleUncaughtError(err, trace);
      const RollbackMutation().rollback(this);
    } finally {
      if (_writeState != null) {
        _readState = _writeState!;
      }
      _writeState = null;
      _visitedPaths.clear();
      _initialized = true;
    }
  }

  // -----------------------------------------------------------------------------
  // Field operations
  // -----------------------------------------------------------------------------
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (!invocation.isAccessor) {
      return;
    }
    final field = invocation.memberName.name!;
    if (invocation.isSetter) {
      final value = invocation.positionalArguments[0];
      _setValue(field, value);
      return;
    }
    return _getValue(field);
  }

  void _setValue(String field, dynamic value) {
    final commitContext = Zone.current[_CommitContext];
    if (commitContext == null) {
      throw VergeError(
          'Change in state should be performed in context of commit');
    }
    // TODO(s-a-sen): maybe we should not check equality because value can be mutable or value has uncommon equality evaluation
    final currentValue =
        _writeState == null ? _readState[field] : _writeState![field];
    if (currentValue == value) {
      return;
    }
    _visitedPaths.add(field);
    _writeState ??= {..._readState};
    _writeState![field] = value;
    return;
  }

  dynamic _getValue(String field) {
    final commitContext = Zone.current[_CommitContext];
    if (commitContext == null) {
      return _readState[field];
    }
    _visitedPaths.add(field);
    if (_writeState == null) {
      return _readState[field];
    }
    return _writeState![field];
  }

  // -----------------------------------------------------------------------------
  // Equality
  // -----------------------------------------------------------------------------
  @override
  bool operator ==(Object other) =>
      other is State &&
      runtimeType == other.runtimeType &&
      _stateEquality.equals(
        _writeState ?? _readState,
        other._writeState ?? other._readState,
      );

  @override
  int get hashCode => _stateEquality.hash(_writeState ?? _readState);

  // -----------------------------------------------------------------------------
  // String representation
  // -----------------------------------------------------------------------------
  @override
  String toString() {
    return '$_readState';
  }
}

// -----------------------------------------------------------------------------
// State Merge
// -----------------------------------------------------------------------------

/// This class perform deep merge for changes in state.
/// For merge this class use Copy-On-Write behaviour.
/// This mean that collection or state will be copied if it contains changes
class DeepStateMerge {
  const DeepStateMerge();

  dynamic merge(dynamic instance) {
    if (instance == null) return instance;
    if (instance is State) return _mergeState(instance);
    if (instance is List) return _mergeList(instance);
    if (instance is Set) return _mergeSet(instance);
    if (instance is Map) return _mergeMap(instance);
    return instance;
  }

  T _mergeState<T extends State>(T instance) {
    if (!instance.isVisited) {
      return instance;
    }
    final maybeNew = _mergeStateMap(
      instance._writeState ?? instance._readState,
      instance._visitedPaths,
    );
    instance._writeState = null;
    final createdState = instance.newState;
    createdState._readState.addAll(maybeNew);
    return createdState as T;
  }

  Map<String, dynamic> _mergeStateMap(
    Map<String, dynamic> instance,
    Set<String> visitedPaths,
  ) {
    if (visitedPaths.isEmpty) {
      return instance;
    }
    Map<String, dynamic>? modifications;
    for (final visitedPath in visitedPaths) {
      final entry = instance[visitedPath];
      final maybeNew = merge(entry);
      if (maybeNew != entry) {
        modifications ??= {};
        modifications[visitedPath] = maybeNew;
      }
    }
    if (modifications == null) {
      return instance;
    }
    return {...instance, ...modifications};
  }

  Map<K, V> _mergeMap<K, V>(Map<K, V> instance) {
    Map<K, V>? modifications;
    for (final entry in instance.entries) {
      final maybeNew = merge(entry.value);
      if (maybeNew != entry.value) {
        modifications ??= {};
        modifications[entry.key] = maybeNew;
      }
    }
    if (modifications == null) {
      return instance;
    }
    return {...instance, ...modifications};
  }

  Set<V> _mergeSet<V>(Set<V> instance) {
    Set<V>? modifications;
    for (final entry in instance) {
      final maybeNew = merge(entry);
      if (maybeNew != entry) {
        modifications ??= {...instance};
        modifications.remove(entry);
        modifications.add(maybeNew);
      }
    }
    if (modifications == null) {
      return instance;
    }
    return modifications;
  }

  List<V> _mergeList<V>(List<V> instance) {
    List<V>? modifications;
    for (final entry in instance.asMap().entries) {
      final maybeNew = merge(entry.value);
      if (maybeNew != entry.value) {
        modifications ??= [...instance];
        modifications[entry.key] = maybeNew;
      }
    }
    if (modifications == null) {
      return instance;
    }
    return modifications;
  }
}

// -----------------------------------------------------------------------------
// State Changes Rollback
// -----------------------------------------------------------------------------

class RollbackMutation {
  const RollbackMutation();

  void rollback(dynamic instance) {
    if (instance == null) return;
    if (instance is State) _rollbackState(instance);
    if (instance is List) _rollbackList(instance);
    if (instance is Set) _rollbackSet(instance);
    if (instance is Map) _rollbackMap(instance);
    return;
  }

  void _rollbackState<T extends State>(T instance) {
    _rollbackMap(
        instance.isModified ? instance._writeState! : instance._readState);
    instance._visitedPaths.clear();
    instance._writeState = null;
  }

  void _rollbackMap<K, V>(Map<K, V> instance) {
    instance.values.forEach(rollback);
  }

  void _rollbackSet<V>(Set<V> instance) {
    instance.forEach(rollback);
  }

  void _rollbackList<V>(List<V> instance) {
    instance.forEach(rollback);
  }
}

// -----------------------------------------------------------------------------
// Deep State Equality
// -----------------------------------------------------------------------------

class DeepStateEquality = DeepCollectionEquality with StateEqualityMixin;

mixin StateEqualityMixin on DeepCollectionEquality {
  static const _baseEquality = DefaultEquality<Never>();

  @override
  bool equals(e1, e2) {
    if (e1 is Set) {
      return e2 is Set && SetEquality(this).equals(e1, e2);
    }
    if (e1 is Map) {
      return e2 is Map && MapEquality(keys: this, values: this).equals(e1, e2);
    }
    if (e1 is List) {
      return e2 is List && ListEquality(this).equals(e1, e2);
    }
    if (e1 is Iterable) {
      return e2 is Iterable && IterableEquality(this).equals(e1, e2);
    }
    return _baseEquality.equals(e1, e2);
  }

  @override
  int hash(Object? o) {
    if (o is Set) {
      return SetEquality(this).hash(o);
    }
    if (o is Map) {
      return MapEquality(keys: this, values: this).hash(o);
    }
    if (o is List) {
      return ListEquality(this).hash(o);
    }
    if (o is Iterable) {
      return IterableEquality(this).hash(o);
    }

    return _baseEquality.hash(o);
  }
}
// -----------------------------------------------------------------------------
// Commit
// -----------------------------------------------------------------------------
typedef StateMutation<S extends State> = S Function(S);

class _CommitContext {
  const _CommitContext();
}

@visibleForTesting
S testCommit<S extends State>(S state, StateMutation<S> mutation) {
  var currentState = state;
  runZoned(() {
    try {
      final mutatedState = mutation(currentState);
      currentState = const DeepStateMerge().merge(mutatedState);
    } catch (err, trace) {
      Zone.current.handleUncaughtError(err, trace);
      const RollbackMutation().rollback(currentState);
    }
  }, zoneValues: {
    _CommitContext: const _CommitContext(),
  });
  return currentState;
}

// -----------------------------------------------------------------------------
// Store
// -----------------------------------------------------------------------------

abstract class Activity {}

abstract class Store<T extends State> extends BlocBase<T> {
  final Lock _storeLock = Lock();
  final _activityController = StreamController<Activity>.broadcast();

  Store(T initialState) : super(initialState);

  Stream<Activity> get activity => _activityController.stream;

  /// Perform synchronized state mutation and return mutated state.
  /// This method should guarantee that commits apply sequentially
  Future<T> commit(T Function(T) mutation) {
    return _storeLock.synchronized(() async {
      var currentState = state;
      return runZoned(() {
        try {
          final mutatedState = mutation(currentState);
          final nextState = const DeepStateMerge().merge(mutatedState);
          emit(nextState);
          return nextState;
        } catch (err, trace) {
          addError(err, trace);
          const RollbackMutation().rollback(currentState);
          rethrow;
        }
      }, zoneValues: {
        _CommitContext: const _CommitContext(),
      });
    });
  }

  /// send subclass of the activity through the activity stream
  void send(covariant Activity activity) {
    _activityController.add(activity);
  }

  @override
  Future<void> close() async {
    await _storeLock.synchronized(() async {
      await _activityController.close();
      await super.close();
    });
  }
}
