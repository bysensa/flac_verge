import 'dart:async';

import 'package:flutter/services.dart';

class TrecMacosApi {
  static const MethodChannel _channel = MethodChannel('trec_macos_api');
  static const EventChannel _activityChannel =
      EventChannel('trec_macos_api/applicationActivity');

  static Stream<dynamic> get activityStream =>
      _activityChannel.receiveBroadcastStream();

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
