import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

// const String linuxP =
//     '/home/thancoder/Documents/ffmpeg-9.0.1-than-media-tag-native-so/binary/linux';
// const String windowP =
//     '/home/thancoder/Documents/ffmpeg-9.0.1-than-media-tag-native-so/binary/window';
// const String androidArm64 =
//     '/home/thancoder/Documents/ffmpeg-9.0.1-than-media-tag-native-so/binary/android-arm64';
// const String androidArm =
//     '/home/thancoder/Documents/ffmpeg-9.0.1-than-media-tag-native-so/binary/android-arm';

const String linuxLibUrl =
    'https://github.com/ThanCoder/mediatag_b/releases/download/mediatag_b.v1/mediatag_b-linux.zip';
const String windowLibUrl =
    'https://github.com/ThanCoder/mediatag_b/releases/download/mediatag_b.v1/mediatag_b-window.zip';
const String androidArm64LibUrl =
    'https://github.com/ThanCoder/mediatag_b/releases/download/mediatag_b.v1/mediatag_b-android-arm64.zip';
const String androidArmLibUr =
    'https://github.com/ThanCoder/mediatag_b/releases/download/mediatag_b.v1/mediatag_b-android-arm.zip';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final packageName = input.packageName;
    final targetArchitecture = input.config.code.targetArchitecture;
    final targetOS = input.config.code.targetOS;
    final libName1 = 'libffmpeg.so';
    final libName2 = 'libffprobe.so';

    // final sourceLib = input.packageRoot.toFilePath()
    //     .join('.dart_tool')
    //     .join('native_assets');
    final packageRootDir = input.packageRoot.toFilePath();
    final sourceLib = p.join(packageRootDir, '.dart_tool', 'native_assets');

    final file1 = await extraceLibSo(
      sourceLib,
      libName: libName1,
      targetOS: targetOS,
      targetArchitecture: targetArchitecture,
    );
    final file2 = await extraceLibSo(
      sourceLib,
      libName: libName2,
      targetOS: targetOS,
      targetArchitecture: targetArchitecture,
    );

    // if (targetOS == .linux) {
    //   file1 = File('$linuxP/$libName1');
    //   file2 = File('$linuxP/$libName2');
    // }
    // if (targetOS == .windows) {
    //   file1 = File('$windowP/$libName1');
    //   file2 = File('$windowP/$libName2');
    // }

    // if (targetOS == .android) {
    //   if (targetArchitecture == .arm64) {
    //     file1 = File('$androidArm64/$libName1');
    //     file2 = File('$androidArm64/$libName2');
    //   }
    //   if (targetArchitecture == .arm) {
    //     file1 = File('$androidArm/$libName1');
    //     file2 = File('$androidArm/$libName2');
    //   }
    // }

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

// extension StringJoin on String {
//   String join(String name) {
//     return '$this${Platform.pathSeparator}$name';
//   }
// }

Future<File> extraceLibSo(
  String sourceLib, {
  required String libName,
  required OS targetOS,
  required Architecture targetArchitecture,
}) async {
  if (targetOS == .linux) {
    // final libFile = File(sourceLib.join(targetOS.name).join(libName));
    final libFile = File(p.join(sourceLib, targetOS.name, libName));
    if (libFile.existsSync()) return libFile;
    // final sourceZipFile = File(sourceLib.join(targetOS.name).join('linux.zip'));
    final sourceZipFile = File(p.join(sourceLib, targetOS.name, 'linux.zip'));
    // zip ရှိရင်
    if (sourceZipFile.existsSync()) {
      await extractZip(sourceZipFile, libFile);
      return libFile;
    }

    await downloadLib(linuxLibUrl, sourceZipFile);
    await extractZip(sourceZipFile, libFile);
    return libFile;
  }
  if (targetOS == .windows) {
    // final libFile = File(sourceLib.join(targetOS.name).join(libName));
    final libFile = File(p.join(sourceLib, targetOS.name, libName));
    if (libFile.existsSync()) return libFile;
    final sourceZipFile = File(
      // sourceLib.join(targetOS.name).join('window.zip'),
      p.join(sourceLib, targetOS.name, 'window.zip'),
    );
    // zip ရှိရင်
    if (sourceZipFile.existsSync()) {
      await extractZip(sourceZipFile, libFile);
      return libFile;
    }

    await downloadLib(windowLibUrl, sourceZipFile);
    await extractZip(sourceZipFile, libFile);
    return libFile;
  }
  // android
  if (targetOS == .android) {
    // final androidLibPath = sourceLib.join(targetOS.name);
    final androidLibPath = p.join(sourceLib, targetOS.name);
    final libFile = File(
      // androidLibPath.join(targetArchitecture.name).join(libName),
      p.join(androidLibPath, targetArchitecture.name, libName),
    );
    if (libFile.existsSync()) return libFile;

    // မရှိရင်
    if (targetArchitecture == .arm) {
      // final sourceZipFile = File(androidLibPath.join('arm.zip'));
      final sourceZipFile = File(p.join(androidLibPath, 'arm.zip'));
      if (sourceZipFile.existsSync()) {
        await extractZip(sourceZipFile, libFile);
        return libFile;
      }
      await downloadLib(androidArmLibUr, sourceZipFile);
      await extractZip(sourceZipFile, libFile);
    }

    if (targetArchitecture == .arm64) {
      // final sourceZipFile = File(androidLibPath.join('arm64.zip'));
      final sourceZipFile = File(p.join(androidLibPath, 'arm64.zip'));

      if (sourceZipFile.existsSync()) {
        await extractZip(sourceZipFile, libFile);
        return libFile;
      }
      await downloadLib(androidArm64LibUrl, sourceZipFile);
      await extractZip(sourceZipFile, libFile);
    }

    return libFile;
  }
  throw UnsupportedError(
    'Os: `$targetOS` - Architecture: `$targetArchitecture`',
  );
}

Future<void> downloadLib(String url, File output) async {
  final client = HttpClient();

  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();

    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'Download failed: ${response.statusCode}',
        uri: Uri.parse(url),
      );
    }

    await output.parent.create(recursive: true);

    final sink = output.openWrite();

    try {
      await response.pipe(sink);
    } finally {
      await sink.close();
    }
  } catch (e) {
    if (await output.exists()) {
      await output.delete();
    }

    rethrow;
  } finally {
    client.close(force: true);
  }
}

Future<void> extractZip(File input, File output) async {
  final bytes = input.readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);
  for (final entry in archive) {
    if (entry.isFile && entry.name.endsWith('.so')) {
      output.parent.createSync(recursive: true);
      await output.writeAsBytes(entry.content, flush: true);
    }
  }
}
