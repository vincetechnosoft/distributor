import 'package:distributor/auth/auth.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/entries/entries.dart';
import 'package:distributor/sellers/create/buy_entry.page.dart';
import 'package:distributor/sellers/create/buyin_payment_entry.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _Options { buy, pay }

class SellersEntriesPage extends StatelessWidget {
  const SellersEntriesPage({Key? key, required this.sellerInfo})
      : super(key: key);

  final SellerInfo sellerInfo;

  @override
  Widget build(BuildContext context) {
    final sellerNumber = sellerInfo.phoneNumber;
    final user = Provider.of<MyAuthUser>(context);
    final stateDoc = DocProvider.of<StateDoc>(context);
    final entries = stateDoc.getSellerEntries(sellerNumber);
    final due = stateDoc.getBuyInDuePayment(sellerNumber);
    final hasWorkerPermission = user.hasWorkerPermission;
    return Scaffold(
      appBar: AppBar(
        title: Text("${sellerInfo.name} Entries"),
        actions: [
          PopupMenuButton<_Options>(
            itemBuilder: (context) {
              return [
                PopupTile(
                  enabled: hasWorkerPermission,
                  child: "Buy Stock",
                  value: _Options.buy,
                  icon: entryTypeToIcon(EntryType.buy),
                ),
                PopupTile(
                  enabled: hasWorkerPermission,
                  child: "Make Payment",
                  value: _Options.pay,
                  icon: entryTypeToIcon(EntryType.buyInPayment),
                ),
              ];
            },
            onSelected: (option) {
              if (option == _Options.pay) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return CreateSellerPaymentEntry(seller: sellerInfo);
                  },
                );
              } else if (option == _Options.buy) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return BuyProduct(sellerNumber: sellerNumber);
                  }),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          itemBuilder: (context, index) {
            if (index-- == 0) {
              return CardTile(
                title: "Payment Due",
                subtitle: "(left to give)",
                trailing: due.toString(),
              );
            }
            if (index-- == 0) return const HeaderTile(title: "Entries");
            final entry = entries.elementAt(index);
            if (entry is BoughtEntry) {
              return BoughtEntryTile(entry: entry);
            } else if (entry is BuyInPaymentEntry) {
              return BuyInEntryTile(entry: entry);
            }
            return const SizedBox();
          },
          separatorBuilder: (context, index) {
            if (index < 2) return const SizedBox();
            return const Divider();
          },
          itemCount: entries.length + 2,
        ),
      ),
    );
  }
}
