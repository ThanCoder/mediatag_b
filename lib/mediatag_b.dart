import 'dart:io';

import 'package:mediatag_b/keys.dart';
import 'package:mediatag_b/utils.dart';

Future<String?> getFFmpegVersionInfo() async {
  final libPath = await getPlatformLibFullPath(ffmpegLibName);

  // await makeExecutableAndRun(libPath);

  final p = await Process.run(libPath, ['-version']);
  return p.stdout;
}

Future<String?> getFFprobeVersionInfo() async {
  final libPath = await getPlatformLibFullPath(ffprobeLibName);

  await makeExecutableAndRun(libPath);

  final p = await Process.run(libPath, ['-version']);
  return p.stdout;
}
