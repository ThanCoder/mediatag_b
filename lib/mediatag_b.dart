import 'dart:io';

import 'package:mediatag_b/core/keys.dart';
import 'package:mediatag_b/core/result_t.dart';
import 'package:mediatag_b/core/types/file_info_res.dart';
import 'package:mediatag_b/core/utils.dart';
import 'package:mediatag_b/core/video_tag.dart';

class MediatagBinary {
  static final MediatagBinary instance = MediatagBinary._();
  MediatagBinary._();
  factory MediatagBinary() => instance;

  late final VideoTag video = VideoTag(binary: this);

  /// audio,video file info
  Future<Result<FileInfoRes, String>> getFileInfo(String path) async {
    // ffprobe -v quiet -print_format json -show_format -show_streams
    try {
      final res = await runFFprobe([
        '-v',
        'quiet',
        '-print_format',
        'json',
        '-show_format',
        '-show_streams',
        path,
      ]);

      if (res.exitCode != 0) {
        final msg = res.stderr.toString();
        return Err(msg.isNotEmpty ? msg : 'Is Error!');
      }
      return Ok(.new(res.stdout.toString()));
    } catch (e) {
      return Err(e.toString());
    }
  }

  /// run ffmpeg
  Future<ProcessResult> runFFmpeg(List<String> commands) async {
    final libPath = await ffmpegLibPath;
    return await Process.run(libPath ?? '', commands);
  }

  /// run ffprobe
  Future<ProcessResult> runFFprobe(List<String> commands) async {
    final libPath = await ffprobeLibPath;
    return await Process.run(libPath ?? '', commands);
  }

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

  /// ffpmpeg version
  Future<String?> getFFmpegVersionInfo() async {
    final libPath = await ffmpegLibPath;
    if (libPath == null) return null;

    final p = await Process.run(libPath, ['-version']);
    return p.stdout;
  }

  /// ffpobe version
  Future<String?> getFFprobeVersionInfo() async {
    final libPath = await ffprobeLibPath;
    if (libPath == null) return null;

    final p = await Process.run(libPath, ['-version']);
    return p.stdout;
  }
}
