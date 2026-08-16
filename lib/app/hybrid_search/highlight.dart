import 'package:flutter/material.dart';

class HighlightText {
  HighlightText._();

  ///高亮某些文字
  static const TextStyle lightTextStyle = TextStyle(
    color: Colors.blue,
    fontWeight: FontWeight.bold,
  );

  static InlineSpan formSpan(String src, String pattern) {
    src = src.replaceAll("\n", "...");
    List<TextSpan> span = [];
    List<String> parts = src.split(pattern);
    if (parts.length > 1) {
      for (int i = 0; i < parts.length; i++) {
        if (parts[i].length <= 20) {
          span.add(TextSpan(text: parts[i]));
        } else {
          String left = parts[i].substring(0, 10);
          String right = parts[i].substring(parts[i].length - 10);

          String r = "$left...$right";
          span.add(TextSpan(text: r));
        }

        if (i != parts.length - 1) {
          span.add(TextSpan(text: pattern, style: lightTextStyle));
        }
      }
    } else {
      span.add(TextSpan(text: src));
    }
    return TextSpan(children: span);
  }

  static InlineSpan multiKeywords(String src, List<String> keywords,
      {bool caseSensitive = true}) {
    if (keywords.isEmpty) {
      return TextSpan(text: src);
    }

    Set<(int, int)> positions = {};
    for (final i in keywords) {
      if (i == "") {
        continue;
      }
      try {
        RegExp reg = RegExp(i, caseSensitive: caseSensitive);
        Iterable<RegExpMatch> matches = reg.allMatches(src);

        for (var element in matches) {
          positions.add((element.start, element.end));
        }
      } catch (_) {
        continue;
      }

      // final l = src.indexOf(i);
    }

    if (positions.isEmpty) {
      return TextSpan(text: src);
    }

    List<(int, int)> p0 = positions.toList()
      ..sort((a, b) => a.$1.compareTo(b.$1));

    // print(p0);

    final set0 = _mergeList(p0);

    // print(set0);

    final List<TextSpan> spans = <TextSpan>[];
    int currentPosition = 0;
    for (final i in set0) {
      if (currentPosition != i.$1) {
        spans.add(TextSpan(text: src.substring(currentPosition, i.$1)));
      }

      spans.add(TextSpan(
        style: lightTextStyle,
        text: src.substring(i.$1, i.$2),
        // recognizer: span.recognizer,
      ));
      currentPosition = i.$2;
    }

    if (currentPosition != src.length) {
      spans.add(TextSpan(
          text: src.substring(
        currentPosition,
      )));
    }

    // print(spans.length);

    return TextSpan(children: spans);
  }

  static Set<(int, int)> _mergeList(List<(int, int)> list) {
    Set<(int, int)> results = {};
    for (int i = 0; i < list.length - 1; i++) {
      if (list[i].$1 == list[i + 1].$1) {
        continue;
      }
      if (list[i].$2 <= list[i + 1].$1) {
        results.add(list[i]);
      } else {
        list[i] = (
          list[i].$1,
          list[i].$2 > list[i + 1].$2 ? list[i].$2 : list[i + 1].$2
        );
        list[i + 1] = list[i];
        results.add(list[i]);
      }
    }
    results.add(list.last);

    return results;
  }
}
