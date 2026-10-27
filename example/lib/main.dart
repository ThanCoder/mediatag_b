// ignore_for_file: avoid_print

import 'dart:io';

import 'package:android_native_path/android_native_path.dart';
import 'package:flutter/material.dart';
import 'package:mediatag_b/keys.dart';
import 'package:mediatag_b/mediatag_b.dart';
import 'package:mediatag_b/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ffmpegPath = await getPlatformLibFullPath(ffmpegLibName);
  final ffprobePath = await getPlatformLibFullPath(ffprobeLibName);
  await makeExecutableAndRun(ffmpegPath);
  await makeExecutableAndRun(ffprobePath);

  if (Platform.isAndroid) {
    print('[:Dev]: ${await AndroidNativePath.instance.nativeLibraries}');
  }

  runApp(MaterialApp(home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const new({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String infoText = '';
  void fetchFFmpeg() async {
    final res = await getFFmpegVersionInfo();
    if (res != null) {
      infoText = res;
      setState(() {});
    }
  }

  void fetchProb() async {
    final res = await getFFprobeVersionInfo();
    if (res != null) {
      infoText = res;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: Column(
        mainAxisSize: .min,
        spacing: 10,
        children: [
          FloatingActionButton(
            heroTag: 'ffmeg',
            onPressed: fetchFFmpeg,
            child: Text('FFmpeg'),
          ),
          FloatingActionButton(
            heroTag: 'FFprob',
            onPressed: fetchProb,
            child: Text('FFprob'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(infoText),
        ),
      ),
    );
  }
}
