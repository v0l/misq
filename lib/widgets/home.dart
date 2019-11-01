import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:misq/lang/messages.dart';
import 'package:misq/theme/base.dart';
import 'package:misq/widgets/button.dart';
import 'package:misq_p2p/internal/network.dart';
import 'package:misq_p2p/proto_dart/proto/proto_v1.2.0.pb.dart';

class HomePage extends StatelessWidget {
  final NetworkReadyNetworkEvent data;

  HomePage({
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: mq.padding,
      decoration: BoxDecoration(
        color: theme.secondary.background,
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: theme.secondary.foreground,
        ),
        child: Column(
          children: <Widget>[
            /// Header
            ///
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: theme.primary.background,
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  _buildMenuButton(theme, "BUY BTC", true),
                  _buildMenuButton(theme, "SELL BTC", false),
                ],
              ),
            ),

            /// Orders
            ///
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: theme.secondaryAccent2.background,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              "BTC",
                              style: TextStyle(color: theme.secondaryAccent2.foreground),
                            ),
                          ),
                          Text(
                            "Amount",
                            style: TextStyle(color: theme.secondaryAccent2.foreground),
                          ),
                          Text(
                            "Payment",
                            style: TextStyle(color: theme.secondaryAccent2.foreground),
                          ),
                          Text(
                            "Actions",
                            style: TextStyle(color: theme.secondaryAccent2.foreground),
                          ),
                        ],
                      ),
                      ...data.response.dataSet
                          .where((a) =>
                              a.whichMessage() == StorageEntryWrapper_Message.protectedStorageEntry &&
                              a.protectedStorageEntry.storagePayload.whichMessage() ==
                                  StoragePayload_Message.offerPayload &&
                              a.protectedStorageEntry.storagePayload.offerPayload.direction ==
                                  OfferPayload_Direction.SELL)
                          .toList()
                          .asMap()
                          .map((i, a) {
                        final offer = a.protectedStorageEntry.storagePayload.offerPayload;
                        return MapEntry(i, _buildOfferRow(theme, offer, i));
                      }).values,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(ThemeType theme, String text, bool isSelected) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? theme.primary.foreground : null,
        border: !isSelected
            ? Border(
                right: BorderSide(
                  color: theme.primary.foreground,
                ),
              )
            : null,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? theme.primary.background : theme.primary.foreground,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  TableRow _buildOfferRow(ThemeType theme, OfferPayload offer, int index) {
    final btcAmount = offer.amount.toDouble() * 1e-8;

    return TableRow(
      decoration: BoxDecoration(
        color: (index % 2 != 0) ? theme.secondary.background : theme.secondaryAccent1.background,
        border: Border(
          bottom: BorderSide(
            color: theme.secondary.foreground,
          ),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text("${NumberFormat.decimalPattern().format(btcAmount)}"),
        ),
        Text(
          NumberFormat.simpleCurrency(name: offer.baseCurrencyCode == "BTC" ? offer.counterCurrencyCode : offer.baseCurrencyCode).format(8200 * btcAmount),
          overflow: TextOverflow.fade,
        ),
        _formatPaymentMethod(theme, offer),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Button(
            decoration: offer.direction == OfferPayload_Direction.BUY
                ? BoxDecoration(
                    color: theme.buttonSell.background,
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  )
                : BoxDecoration(
                    color: theme.buttonBuy.background,
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
            textStyle: TextStyle(
              color: offer.direction == OfferPayload_Direction.BUY
                  ? theme.buttonSell.foreground
                  : theme.buttonBuy.foreground,
            ),
            textContent: offer.direction == OfferPayload_Direction.BUY
                ? "SELL ${offer.baseCurrencyCode}"
                : "BUY ${offer.baseCurrencyCode}",
          ),
        ),
      ],
    );
  }

  Widget _formatPaymentMethod(ThemeType theme, OfferPayload offer) {
    final extra = _getPaymentMethodInfo(offer);
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            M.paymentName(offer.paymentMethodId) + (extra != null ? " ($extra)" : ""),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
      ],
    );
  }

  String _getPaymentMethodInfo(OfferPayload offer) {
    switch (offer.paymentMethodId) {
      default:
        if (offer.countryCode.isNotEmpty) {
          return offer.countryCode;
        }
    }
    return null;
  }
}
