import 'dart:async';
import 'dart:convert';

import 'package:deep_pick/deep_pick.dart';
import 'package:flac/flac.dart';
import 'package:trec_macos_api/trec_macos_api.dart';

import 'service.data.dart';

class PlatformActivityService with Service, Lifecycle {
  StreamSubscription? _activitySubscription;

  @override
  void ensureInitialized() {
    _activitySubscription ??= TrecMacosApi.activityStream
        .map((e) => pick(json.decode(String.fromCharCodes(e))).required())
        .map(PlatformActivity.fromPick)
        .listen(print);

    super.ensureInitialized();
  }

  @override
  void ensureDisposed() {
    _activitySubscription?.cancel();
    super.ensureDisposed();
  }
}
