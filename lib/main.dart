import 'package:flutter/widgets.dart';
import 'package:misq/theme/base.dart';
import 'package:misq/theme/dark.dart';
import 'package:misq/widgets/Launch.dart';

void main() {
  final theme = DarkTheme();

  runApp(Theme(theme, MisqApp()));
}

class MisqApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WidgetsApp(
      title: 'misq',
      color: theme.primary.background,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) =>
          MisqAppPageRoute<T>(settings: settings, builder: builder),
      routes: {
        "/": (ctx) => Launch(),
      },
    );
  }
}

class MisqAppPageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;

  MisqAppPageRoute({
    @required this.builder,
    RouteSettings settings,
  }) : super(settings: settings);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => false;

  @override
  Duration get transitionDuration => Duration.zero;
}
