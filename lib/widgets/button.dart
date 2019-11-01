import 'package:flutter/widgets.dart';
import 'package:misq/theme/base.dart';

class Button extends StatelessWidget {
  final EdgeInsets padding;
  final BoxDecoration decoration;
  final String textContent;
  final Widget widgetContent;
  final TextStyle textStyle;

  Button({
    this.textContent,
    this.widgetContent,
    this.decoration,
    this.padding,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: decoration ??
          BoxDecoration(
            color: theme.primary.background,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
      child: widgetContent ??
          Text(
            textContent,
            softWrap: false,
            style: textStyle,
          ),
    );
  }
}
