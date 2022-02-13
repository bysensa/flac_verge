import 'package:deep_pick/deep_pick.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'service.data.freezed.dart';

class PlatformActivityApplication {
  final String name;
  final String bundleId;
  final int processId;

  const PlatformActivityApplication({
    required this.name,
    required this.bundleId,
    required this.processId,
  });

  PlatformActivityApplication.fromPick(RequiredPick pick)
      : this(
          name: pick('name').asStringOrThrow(),
          bundleId: pick('bundleId').asStringOrThrow(),
          processId: pick('processId').asIntOrThrow(),
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlatformActivityApplication &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          bundleId == other.bundleId &&
          processId == other.processId;

  @override
  int get hashCode => name.hashCode ^ bundleId.hashCode ^ processId.hashCode;

  @override
  String toString() {
    return 'PlatformActivityApplication{name: $name, bundleId: $bundleId, processId: $processId}';
  }
}

@freezed
class PlatformActivity with _$PlatformActivity {
  factory PlatformActivity.fromPick(RequiredPick pick) {
    final type = pick('type').asStringOrThrow();
    switch (type) {
      case 'activate':
        return PlatformActivity.applicationActivate(
          at: pick('at').asDateTimeOrThrow(),
          application: pick('application')
              .letOrThrow(PlatformActivityApplication.fromPick),
        );
      case 'deactivate':
        return PlatformActivity.applicationDeactivate(
          at: pick('at').asDateTimeOrThrow(),
          application: pick('application')
              .letOrThrow(PlatformActivityApplication.fromPick),
        );
      case 'hide':
        return PlatformActivity.applicationHide(
          at: pick('at').asDateTimeOrThrow(),
          application: pick('application')
              .letOrThrow(PlatformActivityApplication.fromPick),
        );
      case 'unhide':
        return PlatformActivity.applicationUnhide(
          at: pick('at').asDateTimeOrThrow(),
          application: pick('application')
              .letOrThrow(PlatformActivityApplication.fromPick),
        );
      case 'launch':
        return PlatformActivity.applicationLaunch(
          at: pick('at').asDateTimeOrThrow(),
          application: pick('application')
              .letOrThrow(PlatformActivityApplication.fromPick),
        );
      case 'terminate':
        return PlatformActivity.applicationTerminate(
          at: pick('at').asDateTimeOrThrow(),
          application: pick('application')
              .letOrThrow(PlatformActivityApplication.fromPick),
        );
      case 'sleep':
        return PlatformActivity.sleep(at: pick('at').asDateTimeOrThrow());
      case 'wake':
        return PlatformActivity.wake(at: pick('at').asDateTimeOrThrow());
      case 'powerOff':
        return PlatformActivity.powerOff(at: pick('at').asDateTimeOrThrow());
      case 'changeSpace':
        return PlatformActivity.changeSpace(at: pick('at').asDateTimeOrThrow());
      case 'lock':
        return PlatformActivity.lock(at: pick('at').asDateTimeOrThrow());
      case 'unlock':
        return PlatformActivity.unlock(at: pick('at').asDateTimeOrThrow());
      default:
        throw FormatException('Unknown platform activity of type $type');
    }
  }

  const factory PlatformActivity.applicationActivate({
    required DateTime at,
    required PlatformActivityApplication application,
  }) = ApplicationActivate;

  const factory PlatformActivity.applicationDeactivate({
    required DateTime at,
    required PlatformActivityApplication application,
  }) = ApplicationDeactivate;

  const factory PlatformActivity.applicationHide({
    required DateTime at,
    required PlatformActivityApplication application,
  }) = ApplicationHide;

  const factory PlatformActivity.applicationUnhide({
    required DateTime at,
    required PlatformActivityApplication application,
  }) = ApplicationUnhide;

  const factory PlatformActivity.applicationLaunch({
    required DateTime at,
    required PlatformActivityApplication application,
  }) = ApplicationLaunch;

  const factory PlatformActivity.applicationTerminate({
    required DateTime at,
    required PlatformActivityApplication application,
  }) = ApplicationTerminate;

  const factory PlatformActivity.sleep({
    required DateTime at,
  }) = Sleep;

  const factory PlatformActivity.wake({
    required DateTime at,
  }) = Wake;

  const factory PlatformActivity.powerOff({
    required DateTime at,
  }) = PowerOff;

  const factory PlatformActivity.changeSpace({
    required DateTime at,
  }) = ChangeSpace;

  const factory PlatformActivity.lock({
    required DateTime at,
  }) = Lock;

  const factory PlatformActivity.unlock({
    required DateTime at,
  }) = Unlock;
}
