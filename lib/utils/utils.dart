import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getAssetPath(String asset) async {
  final String path = await getLocalPath(asset);

  await Directory(dirname(path)).create(recursive: true);

  final File file = .new(path);
  if (!await file.exists()) {
    final ByteData byteData = await rootBundle.load(asset);
    await file.writeAsBytes(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
    );
  }

  return file.path;
}

Future<String> getLocalPath(String path) async {
  return '${(await getApplicationSupportDirectory()).path}/$path';
}

Future<File?> cropImage(File imageFile, DetectedObject object) async {
  final img.Image? parse = await img.decodeImageFile(imageFile.absolute.path);
  if (parse == null) return null;
  final img.Image result = img.copyCrop(
    parse,
    x: object.boundingBox.left.toInt(),
    y: object.boundingBox.top.toInt(),
    width: (object.boundingBox.right - object.boundingBox.left).toInt(),
    height: (object.boundingBox.bottom - object.boundingBox.top).toInt(),
  );

  List<int> cropByte = [];
  cropByte = img.encodeJpg(result);
  final File imageFileCrop = await .new(
    imageFile.absolute.path,
  ).writeAsBytes(cropByte);
  return imageFileCrop;
}

Future<File?> cropPassportMrz(File imageFile, DetectedObject object) async {
  final img.Image? parse = await img.decodeImageFile(imageFile.absolute.path);
  if (parse == null) return null;

  final img.Image passportCrop = img.copyCrop(
    parse,
    x: object.boundingBox.left.toInt(),
    y: object.boundingBox.top.toInt(),
    width: (object.boundingBox.right - object.boundingBox.left).toInt(),
    height: (object.boundingBox.bottom - object.boundingBox.top).toInt(),
  );

  final int mrzHeight = (passportCrop.height * 0.25).toInt();
  final int mrzY = passportCrop.height - mrzHeight;

  final img.Image mrzCrop = img.copyCrop(
    passportCrop,
    x: 0,
    y: mrzY,
    width: passportCrop.width,
    height: mrzHeight,
  );

  final img.Image enhanced = img.contrast(mrzCrop, contrast: 1.2);
  final img.Image sharpened = img.convolution(
    enhanced,
    filter: [0, -1, 0, -1, 5, -1, 0, -1, 0],
  );

  final List<int> cropByte = img.encodeJpg(sharpened);
  final String tempPath =
      '${imageFile.parent.path}/mrz_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final File mrzFile = await .new(tempPath).writeAsBytes(cropByte);
  return mrzFile;
}

String calculateCheckDigit(String input) {
  const weights = [7, 3, 1];
  int sum = 0;

  final String cleanInput = input
      .replaceAll('«', '<')
      .replaceAll('»', '<')
      .replaceAll('‹', '<')
      .replaceAll('›', '<')
      .replaceAll('〈', '<')
      .replaceAll('〉', '<')
      .replaceAll('＜', '<')
      .replaceAll('＞', '<');

  for (int i = 0; i < cleanInput.length; i++) {
    final String char = cleanInput[i];
    int value;

    if (char == '<') {
      value = 0;
    } else if (RegExp(r'\d').hasMatch(char)) {
      value = int.parse(char);
    } else {
      value = char.codeUnitAt(0) - 'A'.codeUnitAt(0) + 10;
    }

    sum += value * weights[i % 3];
  }

  return (sum % 10).toString();
}

bool validateMrzChecksum(String data, String checkDigit) {
  return calculateCheckDigit(data) == checkDigit;
}
