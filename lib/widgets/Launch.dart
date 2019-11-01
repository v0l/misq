import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:misq/net.dart';
import 'package:misq/theme/base.dart';
import 'package:misq/widgets/home.dart';
import 'package:misq_p2p/misq_p2p.dart';

class Launch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final net = Network.of(context);

    return StreamBuilder<NetworkEvent>(
      stream: net.events,
      builder: (context, state) {
        if (state.data is NetworkReadyNetworkEvent) {
          return HomePage(data: state.data);
        } else {
          return _buildSplashScreen(theme, (state.data as NewPeerNetworkEvent)?.peerCount ?? 0);
        }
      },
    );
  }

  Widget _buildSplashScreen(ThemeType theme, int peers) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.secondary.background,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          /// Logo
          ///
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Image.asset("assets/images/logo_splash@2x.png"),
          ),

          /// Status
          ///
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text("${peers ?? 0} peers connected"),
          ),

          /// Loader
          ///
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: SpinKitFadingCube(
              color: theme.secondary.foreground,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
