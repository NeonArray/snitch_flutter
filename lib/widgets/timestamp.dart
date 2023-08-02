import 'package:flutter/material.dart';

class Timestamp extends StatelessWidget {
  const Timestamp({
    super.key,
    required this.time,
  });

  final String time;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).extension<TimestampTheme>();
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 90,
      ),
      decoration: BoxDecoration(
        color: theme?.background,
        border: Border.all(
          color: theme != null ? theme.borderColor : Colors.grey,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Text(
        time,
        style: TextStyle(
          color: theme?.fontColor,
          fontSize: 10,
        ),
      ),
    );
  }
}

@immutable
class TimestampTheme extends ThemeExtension<TimestampTheme> {
  const TimestampTheme({
    this.background = Colors.black45,
    this.borderColor = Colors.grey,
    this.fontColor = Colors.white,
  });

  final Color background;
  final Color borderColor;
  final Color fontColor;

  @override
  ThemeExtension<TimestampTheme> copyWith({
    Color? background,
    Color? borderColor,
    Color? fontColor,
  }) {
    return TimestampTheme(
      background: background ?? this.background,
      borderColor: borderColor ?? this.borderColor,
      fontColor: fontColor ?? this.fontColor,
    );
  }

  @override
  ThemeExtension<TimestampTheme> lerp(
    ThemeExtension<TimestampTheme>? other,
    double t,
  ) {
    if (other is! TimestampTheme || t == 1.0) return this;

    return TimestampTheme(
      background: Color.lerp(background, other.background, t)!,
    );
  }
}
