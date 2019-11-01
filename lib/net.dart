import 'package:flutter/widgets.dart';
import 'package:misq_p2p/internal/network.dart';

class Network extends InheritedWidget {
  final BisqNetwork net;

  Network({
    Widget child,
    this.net,
  }) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  static BisqNetwork of(BuildContext context) => (context.inheritFromWidgetOfExactType(Network) as Network)?.net;
}
