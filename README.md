# KTP Extractor

A Flutter package for extracting information from Indonesian ID cards (Kartu Tanda Penduduk - KTP) using Google’s ML Kit for object detection and text recognition.

## Features

-	**Automatic KTP Detection and Cropping**: Detects the KTP area within an image and crops it for processing.
-	**Text Recognition**: Extracts text from the KTP image using OCR.
-	**Data Parsing**: Parses the recognized text to extract specific fields such as NIK, name, birth date, address, and more.
-	**Easy Integration**: Simple API to integrate into your Flutter applications.

## Requirements

### iOS

- Minimum iOS Deployment Target: 15.5.0
- Xcode 15.3.0 or newer
- Swift 5
- ML Kit does not support 32-bit architectures (i386 and armv7). ML Kit does support 64-bit architectures (x86_64 and arm64). Check this [list](https://developer.apple.com/support/required-device-capabilities/) to see if your device has the required device capabilities. More info [here](https://developers.google.com/ml-kit/migration/ios).

Since ML Kit does not support 32-bit architectures (i386 and armv7), you need to exclude armv7 architectures in Xcode in order to run `flutter build ios` or `flutter build ipa`. More info [here](https://developers.google.com/ml-kit/migration/ios).

Go to Project > Runner > Building Settings > Excluded Architectures > Any SDK > armv7

<p align="center" width="100%">
  <img src="https://raw.githubusercontent.com/flutter-ml/google_ml_kit_flutter/master/resources/build_settings_01.png">
</p>

Your Podfile should look like this:

```ruby
platform :ios, '15.5.0'  # or newer version

...

# add this line:
$iOSVersion = '15.5.0'  # or newer version

post_install do |installer|
  # add these lines:
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=*]"] = "armv7"
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = $iOSVersion
  end

  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    # add these lines:
    target.build_configurations.each do |config|
      if Gem::Version.new($iOSVersion) > Gem::Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = $iOSVersion
      end
    end

  end
end
```

add to the `ios/Podfile` file:

```ruby
# Add language package you need to use
pod 'GoogleMLKit/TextRecognitionChinese', '~> 7.0.0'
pod 'GoogleMLKit/TextRecognitionDevanagari', '~> 7.0.0'
pod 'GoogleMLKit/TextRecognitionJapanese', '~> 7.0.0'
pod 'GoogleMLKit/TextRecognitionKorean', '~> 7.0.0'
```

Notice that the minimum `IPHONEOS_DEPLOYMENT_TARGET` is 15.5.0, you can set it to something newer but not older.

### Android

- minSdkVersion: 21
- targetSdkVersion: 33
- compileSdkVersion: 34

Add to the `android/app/build.gradle`

```gradle
dependencies {
    // Add language package you need to use
    implementation 'com.google.mlkit:text-recognition-chinese:16.0.0'
    implementation 'com.google.mlkit:text-recognition-devanagari:16.0.0'
    implementation 'com.google.mlkit:text-recognition-japanese:16.0.0'
    implementation 'com.google.mlkit:text-recognition-korean:16.0.0'
}
```

## Usage

### Extract Information from a KTP Image
```dart
import 'dart:io';
import 'package:ktp_extractor/ktp_extractor.dart';

void main() async {
  // Load your image file (ensure it contains a KTP)
  File imageFile = File('path_to_your_image.jpg');

  // Crop the image to the KTP area (optional but recommended)
  File? croppedImage = await KtpExtractor.cropImageForKtp(imageFile);

  // Use the cropped image for extraction if available
  File imageToProcess = croppedImage ?? imageFile;

  // Extract KTP information
  KtpModel ktpData = await KtpExtractor.extractKtp(imageToProcess);

  // Access the extracted data
  print('NIK: ${ktpData.nik}');
  print('Name: ${ktpData.name}');
  print('Birth Date: ${ktpData.birthDay}');
  print('Address: ${ktpData.address}');
  // ... access other fields as needed
}
```

## Reference
This plugin reference from [MNC Identifier OCR](https://pub.dev/packages/mnc_identifier_ocr).

## Issues
Have any question, bugs, issues, or feature request you can go to our [GitHub](https://github.com/Irfan234-afif/ktp_extractor/issues).
