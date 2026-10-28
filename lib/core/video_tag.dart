import 'package:mediatag_b/core/result_t.dart';
import 'package:mediatag_b/mediatag_b.dart';

enum VideoThumbnailType { jpg, png }

extension DurationX on Duration {
  String toTimeString() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(inHours);
    String minutes = twoDigits(inMinutes.remainder(60));
    String seconds = twoDigits(inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}

class VideoTag {
  final MediatagBinary _binary;

  const VideoTag({required this._binary});

  ///generate video thumbnail
  ///
  /// output-> `'$thumbnailPath.${type.name}'`
  Future<Result<bool, String>> genThumbnail(
    String input,
    String thumbnailPath, {
    Duration duration = const Duration(seconds: 5),
    VideoThumbnailType type = .jpg,
  }) async {
    try {
      //ffmpeg -ss 00:00:05 -i input.mp4 -vframes 1 thumbnail.jpg
      final res = await _binary.runFFmpeg([
        '-ss',
        duration.toTimeString(),
        '-i',
        input,
        '-vframes',
        '1',
        '-vf',
        'format=yuv420p', // format ကို အတင်းဖိပြောင်းခိုင်းခြင်း
        '$thumbnailPath.${type.name}',
      ]);
      if (res.exitCode == 0) return Ok(true);
      final msg = res.stderr.toString();
      return Err(msg.isNotEmpty ? msg : 'Is Error!');
    } catch (e) {
      return Err(e.toString());
    }
  }
}

// ./ffmpeg -ss 00:00:05 -i "/home/thancoder/Videos/Jennifer Body.mp4" -vframes 1 -vf format=yuv420p "/home/thancoder/Videos/Jennifer Body.jpg"
