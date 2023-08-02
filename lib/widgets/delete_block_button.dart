import 'package:flutter/material.dart';

class DeleteBlockButton extends StatelessWidget {
  final void Function()? callback;

  const DeleteBlockButton({
    super.key,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).extension<DeleteBlockButtonTheme>();
    return IconButton(
      onPressed: callback,
      icon: const Icon(
        Icons.do_not_disturb_alt_rounded,
      ),
      color: theme?.iconColor,
      iconSize: 14,
      style: ButtonStyle(
        padding: MaterialStateProperty.all(
          const EdgeInsets.all(0),
        ),
      ),
    );
  }
}

@immutable
class DeleteBlockButtonTheme extends ThemeExtension<DeleteBlockButtonTheme> {
  const DeleteBlockButtonTheme({
    this.iconColor = Colors.grey,
  });

  final Color iconColor;

  @override
  ThemeExtension<DeleteBlockButtonTheme> copyWith({
    Color? fontColor,
  }) {
    return DeleteBlockButtonTheme(
      iconColor: iconColor,
    );
  }

  @override
  ThemeExtension<DeleteBlockButtonTheme> lerp(
    ThemeExtension<DeleteBlockButtonTheme>? other,
    double t,
  ) {
    if (other is! DeleteBlockButtonTheme || t == 1.0) return this;

    return DeleteBlockButtonTheme(
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
    );
  }
}
