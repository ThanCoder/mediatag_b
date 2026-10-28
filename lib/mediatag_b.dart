import 'dart:io';

import 'package:mediatag_b/core/keys.dart';
import 'package:mediatag_b/core/utils.dart';

class MediatagBinary {
  static final MediatagBinary instance = MediatagBinary._();
  MediatagBinary._();
  factory MediatagBinary() => instance;

  /// ffmpeg binary fullpath
  Future<String?> get ffmpegLibPath async =>
      await getPlatformLibFullPath(ffmpegLibName);

  /// ffprobe binary fullpath
  Future<String?> get ffprobeLibPath async =>
      await getPlatformLibFullPath(ffprobeLibName);

  /// binary initailize
  Future<void> initailize() async {
    final fflibPath = await ffmpegLibPath;
    final ffprobelibPath = await ffprobeLibPath;
    if (fflibPath != null) {
      await makeExecutableAndRun(fflibPath);
    }
    if (ffprobelibPath != null) {
      await makeExecutableAndRun(ffprobelibPath);
    }
  }

  Future<String?> getFFmpegVersionInfo() async {
    final libPath = await ffmpegLibPath;
    if (libPath == null) return null;

    final p = await Process.run(libPath, ['-version']);
    return p.stdout;
  }

  Future<String?> getFFprobeVersionInfo() async {
    final libPath = await ffprobeLibPath;
    if (libPath == null) return null;

    final p = await Process.run(libPath, ['-version']);
    return p.stdout;
  }
}
