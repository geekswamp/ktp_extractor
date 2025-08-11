import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:string_similarity/string_similarity.dart';

extension TextLineExt on RecognizedText {
  String? findAndClean(TextLine line, String key) {
    if (line.elements.length > key.split(" ").length) {
      return line.text.cleanse(key);
    } else {
      return findInline(line)?.text.cleanse(key);
    }
  }

  TextLine? findInline(TextLine line) {
    final double top = line.boundingBox.top;
    final double bottom = line.boundingBox.bottom;

    final List<TextLine> result = [];

    for (final block in blocks) {
      for (final textLine in block.lines) {
        final centerY =
            (textLine.boundingBox.bottom + textLine.boundingBox.top) / 2;

        if (centerY >= top && centerY <= bottom && textLine.text != line.text) {
          result.add(textLine);
        }
      }
    }

    if (result.isEmpty) return null;

    // Find the line with the minimum left position
    return result.reduce((a, b) {
      final leftA = a.boundingBox.left;
      final leftB = b.boundingBox.left;
      return leftA < leftB ? a : b;
    });
  }
}

extension StringExtension on String {
  String filterNumbersOnly() {
    final String corrected = replaceAll('O', '0')
        .replaceAll('o', '0')
        .replaceAll('I', '1')
        .replaceAll('l', '1')
        .replaceAll('B', '8')
        .replaceAll('b', '6')
        .replaceAll('S', '5')
        .replaceAll('Z', '2')
        .replaceAll('z', '2')
        .replaceAll('D', '0')
        .replaceAll('A', '4')
        .replaceAll('e', '2')
        .replaceAll('L', '6')
        .replaceAll('T', '7');

    return corrected.removeAlphabet();
  }

  String removeAlphabet() {
    return replaceAll(RegExp(r'[^0-9]'), '');
  }

  String cleanse(String text, {bool ignoreCase = true}) {
    String cleaned = this;

    // Replace text with an empty string, respecting case sensitivity
    if (ignoreCase) {
      cleaned = cleaned.replaceAll(RegExp(text, caseSensitive: false), '');
    } else {
      cleaned = cleaned.replaceAll(text, '');
    }

    // Remove colons and trim whitespace
    cleaned = cleaned.replaceAll(':', '').trim();

    return cleaned;
  }

  String filterNumberToAlphabet() {
    return replaceAll('0', 'O')
        .replaceAll('1', 'I')
        .replaceAll('4', 'A')
        .replaceAll('5', 'S')
        .replaceAll('7', 'T')
        .replaceAll('8', 'B');
  }

  String filterAlphabetToNumber() {
    return replaceAll('O', '0')
        .replaceAll('o', '0')
        .replaceAll('I', '1')
        .replaceAll('l', '1')
        .replaceAll('B', '8')
        .replaceAll('b', '6')
        .replaceAll('S', '5')
        .replaceAll('Z', '2')
        .replaceAll('z', '2')
        .replaceAll('D', '0')
        .replaceAll('A', '4')
        .replaceAll('e', '2')
        .replaceAll('L', '6')
        .replaceAll('T', '7');
  }

  String? correctWord(List<String> expectedWords, {bool safetyBack = false}) {
    /// define zero initial and increase when add similar from word
    /// this is same with confidence in AI
    double highestSimilarity = 0.0;
    String closestWord = this;

    for (final word in expectedWords) {
      final double similarity = similarityTo(word);
      if (similarity > highestSimilarity) {
        highestSimilarity = similarity;
        closestWord = word;
      }
    }

    if (!safetyBack && highestSimilarity < 0.5) {
      return null;
    }
    return closestWord;
  }

  String cleanMrzText() {
    return toUpperCase()
        .replaceAll('«', '<')
        .replaceAll('»', '<')
        .replaceAll('‹', '<')
        .replaceAll('›', '<')
        .replaceAll('〈', '<')
        .replaceAll('〉', '<')
        .replaceAll('＜', '<')
        .replaceAll('＞', '<')
        .replaceAll(RegExp(r'[^A-Z0-9<]'), '')
        .replaceAll('0', 'O')
        .replaceAll('1', 'I')
        .replaceAll('8', 'B')
        .replaceAll('5', 'S');
  }

  String normalizeMrzLine() {
    String normalized = cleanMrzText();
    if (normalized.length < 44) {
      normalized = normalized.padRight(44, '<');
    } else if (normalized.length > 44) {
      normalized = normalized.substring(0, 44);
    }
    return normalized;
  }

  List<String> extractMrzLines(String fullText) {
    print("extract");
    final lines = fullText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    List<String> mrzLines = [];

    for (String line in lines) {
      final cleanedLine = line.cleanMrzText();

      // MRZ Line 1: Must start with P< for passport
      bool isMrzLine1 = cleanedLine.startsWith('P<') ||
          cleanedLine.startsWith('P«') ||
          cleanedLine.startsWith('P‹') ||
          cleanedLine.startsWith('P〈') ||
          cleanedLine.startsWith('P＜');

      // MRZ Line 2: Must have at least 3 consecutive < characters or variants
      bool isMrzLine2 = RegExp(r'[<«»‹›〈〉＜＞]{3,}').hasMatch(cleanedLine) &&
          cleanedLine.length >= 40 &&
          !cleanedLine.startsWith('P') &&
          RegExp(r'[A-Z0-9]{6,}').hasMatch(cleanedLine);

      if (isMrzLine1 || (isMrzLine2 && cleanedLine.length >= 36)) {
        print("line : ${line}");
        print("cleanedLine : ${cleanedLine}");
        print("isMrzLine1: $isMrzLine1, isMrzLine2: $isMrzLine2");
        mrzLines.add(cleanedLine.normalizeMrzLine());
      }
    }

    if (mrzLines.length >= 2) {
      print("mrzline > 2 : ${mrzLines.toString()}");
      return mrzLines.take(2).toList();
    }

    return mrzLines;
  }
}
