// ignore_for_file: avoid_print

import 'dart:io';

import 'package:android_native_path/android_native_path.dart';
import 'package:flutter/material.dart';
import 'package:mediatag_b/mediatag_b.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MediatagBinary.instance.initailize();

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
  final pkg = MediatagBinary.instance;

  String infoText = '';

  void fetchFFmpeg() async {
    final res = await pkg.getFFmpegVersionInfo();
    if (res != null) {
      infoText = res;
      setState(() {});
    }
  }

  void fetchProb() async {
    final res = await pkg.getFFprobeVersionInfo();
    if (res != null) {
      infoText = res;
      setState(() {});
    }
  }

  void showInfo(String path) async {
    final res = await pkg.getFileInfo(path);
    if (res.isOk) {
      infoText = res.unwrap().text;
      // final format = res.unwrap().toMap['format'];
      // print(format);
    }
    if (res.isErr) {
      infoText = res.unwrapError();
    }
    setState(() {});
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
            child: Text('FFmpeg Version'),
          ),
          FloatingActionButton(
            heroTag: 'FFprob',
            onPressed: fetchProb,
            child: Text('FFprob Version'),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _btns),
          SliverToBoxAdapter(child: Text(infoText)),
        ],
      ),
    );
  }

  Widget get _btns {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        FilledButton(
          onPressed: () => showInfo('/home/thancoder/Videos/Jennifer Body.mp4'),
          child: Text('Video Info'),
        ),
        FilledButton(
          onPressed: () => showInfo(
            '/home/thancoder/Music/The Crew - Get Low [GMV] [oQ6KD_FTix0].m4a',
          ),
          child: Text('Audio Info'),
        ),
        FilledButton(
          onPressed: () {
            pkg.video
                .genThumbnail(
                  '/home/thancoder/Videos/Jennifer Body.mp4',
                  '/home/thancoder/Videos/Jennifer Body',
                )
                .then((res) {
                  if (res.isErr) {
                    infoText = res.unwrapError();
                    if (!mounted) return;
                    setState(() {});
                  }
                });
          },
          child: Text('Gen Video Thumbnail'),
        ),
      ],
    );
  }
}
