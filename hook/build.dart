import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

// const String linuxP =
//     '/home/thancoder/Documents/ffmpeg-9.0.1-than-media-tag-native-so/binary/linux';
// const String windowP =
//     '/home/thancoder/Documents/ffmpeg-9.0.1-than-media-tag-native-so/binary/window';
// const String androidArm64 =
//     '/home/thancoder/Documents/ffmpeg-9.0.1-than-media-tag-native-so/binary/android-arm64';
// const String androidArm =
//     '/home/thancoder/Documents/ffmpeg-9.0.1-than-media-tag-native-so/binary/android-arm';

const String linuxP =
    'https://github.com/ThanCoder/mediatag_b/releases/download/mediatag_b.v1/mediatag_b-linux.zip';
const String windowP =
    'https://github.com/ThanCoder/mediatag_b/releases/download/mediatag_b.v1/mediatag_b-window.zip';
const String androidArm64 =
    'https://github.com/ThanCoder/mediatag_b/releases/download/mediatag_b.v1/mediatag_b-android-arm64.zip';
const String androidArm =
    'https://github.com/ThanCoder/mediatag_b/releases/download/mediatag_b.v1/mediatag_b-android-arm.zip';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final packageName = input.packageName;
    final targetArchitecture = input.config.code.targetArchitecture;
    final targetOS = input.config.code.targetOS;
    final libName1 = 'libffmpeg.so';
    final libName2 = 'libffprobe.so';

    late File file1;
    late File file2;

    if (targetOS == .linux) {
      file1 = File('$linuxP/$libName1');
      file2 = File('$linuxP/$libName2');
    }
    if (targetOS == .windows) {
      file1 = File('$windowP/$libName1');
      file2 = File('$windowP/$libName2');
    }

    if (targetOS == .android) {
      if (targetArchitecture == .arm64) {
        file1 = File('$androidArm64/$libName1');
        file2 = File('$androidArm64/$libName2');
      }
      if (targetArchitecture == .arm) {
        file1 = File('$androidArm/$libName1');
        file2 = File('$androidArm/$libName2');
      }
    }

    output.assets.code.add(
      .new(
        package: packageName,
        name: libName1,
        linkMode: DynamicLoadingBundled(),
        file: file1.uri,
      ),
    );
    output.assets.code.add(
      .new(
        package: packageName,
        name: libName2,
        linkMode: DynamicLoadingBundled(),
        file: file2.uri,
      ),
    );
  });
}
