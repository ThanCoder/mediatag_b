import 'dart:io';

import 'package:archive/archive.dart';
import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:mediatag_b/core/keys.dart';
import 'package:path/path.dart' as p;

const String linuxLibUrl =
    'https://github.com/ThanCoder/mediatag_b/releases/download/mediatag_b.v2/mediatag_b_binary-linux.zip';
const String windowLibUrl =
    'https://github.com/ThanCoder/mediatag_b/releases/download/mediatag_b.v2/mediatag_b_binary-window.zip';
const String androidArm64LibUrl =
    'https://github.com/ThanCoder/mediatag_b/releases/download/mediatag_b.v2/mediatag_b_binary-android-arm64.zip';
const String androidArmLibUr =
    'https://github.com/ThanCoder/mediatag_b/releases/download/mediatag_b.v2/mediatag_b_binary-android-arm.zip';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final packageName = input.packageName;
    final packageRootDir = input.packageRoot.toFilePath();
    final sourceLib = p.join(packageRootDir, '.dart_tool', 'native_assets');

    final ffmpegLib = LibArchiveConfig.create(
      input.config.code,
      sourceLib,
      ffmpegLibName,
    );

    await extractLib(ffmpegLib);

    output.assets.code.add(
      .new(
        package: packageName,
        name: ffmpegLibName,
        linkMode: DynamicLoadingBundled(),
        file: ffmpegLib.libOutFile.uri,
      ),
    );
    output.assets.code.add(
      .new(
        package: packageName,
        name: ffprobeLibName,
        linkMode: DynamicLoadingBundled(),
        file: File(p.join(ffmpegLib.libOutFile.parent.path, ffprobeLibName))
            .uri,
      ),
    );
  });
}

Future<void> extractLib(LibArchiveConfig config) async {
  if (config.libOutFile.existsSync()) return;
  if (config.libZipFile.existsSync()) {
    await extractZip(config.libZipFile, config.libOutFile.parent);
    return;
  }
  await downloadLib(config.downloadUrl, config.libZipFile);
  await extractZip(config.libZipFile, config.libOutFile.parent);
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

Future<void> extractZip(File input, Directory outputFolder) async {
  final bytes = input.readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);
  for (final entry in archive) {
    if (entry.isFile && entry.name.endsWith('.so')) {
      outputFolder.createSync(recursive: true);
      File(p.join(outputFolder.path, entry.name))
          .writeAsBytes(entry.content, flush: true);
    }
  }
}

class LibArchiveConfig {
  const LibArchiveConfig({
    required this.config,
    required this.libOutFile,
    required this.downloadUrl,
    required this.libZipFile,
  });

  final CodeConfig config;
  final File libOutFile;
  final File libZipFile;
  final String downloadUrl;

  factory LibArchiveConfig.create(
    CodeConfig cf,
    String sourceLib,
    String libName,
  ) {
    final targetOS = cf.targetOS;
    final targetArch = cf.targetArchitecture;

    if (cf.targetOS == .linux) {
      final libOutPath = File(p.join(sourceLib, targetOS.name, libName));
      return .new(
        config: cf,
        libOutFile: libOutPath,
        downloadUrl: linuxLibUrl,
        libZipFile: File(p.join(sourceLib, targetOS.name, 'linux.zip')),
      );
    }
    if (cf.targetOS == .windows) {
      final libOutPath = File(p.join(sourceLib, targetOS.name, libName));
      return .new(
        config: cf,
        libOutFile: libOutPath,
        downloadUrl: windowLibUrl,
        libZipFile: File(p.join(sourceLib, targetOS.name, 'window.zip')),
      );
    }
    if (targetOS == .android) {
      final androidLibPath = p.join(sourceLib, targetOS.name);
      final libOutFile = File(p.join(androidLibPath, targetArch.name, libName));
      final downloadUrl = switch (targetArch) {
        .arm => androidArmLibUr,
        .arm64 => androidArm64LibUrl,
        _ => UnsupportedError('error: ${targetOS.name} - ${targetArch.name}'),
      };
      return .new(
        config: cf,
        libOutFile: libOutFile,
        downloadUrl: downloadUrl as String,
        libZipFile: File(p.join(androidLibPath, '${targetArch.name}.zip')),
      );
    }

    throw UnsupportedError('Not Supported: ${targetArch.name}');
  }
}
