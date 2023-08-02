import 'package:flutter/material.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/theme_map.dart';

import '../models/block.dart';

class CodeBlock extends StatelessWidget {
  const CodeBlock({
    super.key,
    required Block data,
  }) : _data = data;

  final Block _data;

  @override
  Widget build(BuildContext context) {
    var theme =
        Theme.of(context).extension<CodeBlockTheme>() ?? const CodeBlockTheme();

    return Container(
      decoration: BoxDecoration(
        // color: Colors.black54,
        color: theme.background,
        border: theme.border,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HighlightView(
            _data.code ?? "",
            language: _data.language,
            theme: themeMap["gruvbox-dark"]!,
            padding: const EdgeInsets.all(12),
            textStyle: TextStyle(
              fontFamily: theme.fontFamily,
            ),
          ),
          const SizedBox(height: 10),
          // TextButton(
          //   onPressed: () async {
          // var url = Uri(
          //   scheme: "phpstorm",
          //   path: "open",
          //   queryParameters: {
          //     "file": _data.origin.file,
          //     "line": _data.origin.lineNumber.toString(),
          //   },
          // );
          /**
               * TODO: This won't work cause url_launcher doesnt seem to allow custom protocols. The other issue too is that we would need to somehow know which protocol to call.
                */
          // await launchUrl(url);
          // },
          // child: Text(
          Text(
            "${_data.origin.file} : ${_data.origin.lineNumber}",
            style: TextStyle(
              color: theme.fontColor,
              fontSize: 9,
              decoration: TextDecoration.underline,
              // ),
            ),
          ),
        ],
      ),
    );
  }
}

@immutable
class CodeBlockTheme extends ThemeExtension<CodeBlockTheme> {
  const CodeBlockTheme({
    this.background = Colors.black45,
    this.border = const Border(
      bottom: BorderSide(
        color: Colors.white10,
        width: 1,
      ),
    ),
    this.fontFamily = 'SFMono-Regular,Consolas,Liberation Mono,Menlo,monospace',
    this.fontColor = Colors.grey,
  });

  final Color background;
  final Border border;
  final String fontFamily;
  final Color fontColor;

  @override
  CodeBlockTheme copyWith({
    Color? background,
    Border? border,
    Color? fontColor,
    String? fontFamily,
  }) {
    return CodeBlockTheme(
      background: background ?? this.background,
      border: border ?? this.border,
      fontColor: fontColor ?? this.fontColor,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  @override
  CodeBlockTheme lerp(
    CodeBlockTheme? other,
    double t,
  ) {
    if (other is! CodeBlockTheme || t == 1.0) return this;

    return CodeBlockTheme(
      background: Color.lerp(background, other.background, t)!,
    );
  }
}
