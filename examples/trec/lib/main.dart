import 'package:flac/flac.dart';
import 'package:flutter/material.dart';
import 'package:trec/infrastructure/platform_activity/service.dart';

void main() {
  runApp(
    AppWidget(
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late PlatformActivityService platformActivityService;

  @override
  void initState() {
    super.initState();
    platformActivityService = PlatformActivityService()..ensureInitialized();
  }

  @override
  void dispose() {
    platformActivityService.ensureDisposed();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Placeholder(),
    );
  }
}
