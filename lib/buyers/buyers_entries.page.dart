import 'package:distributor/auth/auth.dart';
import 'package:distributor/buyers/create/return_boxes_entry.dart';
import 'package:distributor/buyers/create/sell_entry.page.dart';
import 'package:distributor/buyers/create/sellout_payment_entry.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/entries/entries.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _Options { buy, pay, returnBoxes }

class BuyersEntriesPage extends StatelessWidget {
  const BuyersEntriesPage({Key? key, required this.buyerInfo})
      : super(key: key);
  final BuyerInfo buyerInfo;

  @override
  Widget build(BuildContext context) {
    final buyerNumber = buyerInfo.phoneNumber;
    final user = Provider.of<MyAuthUser>(context);
    final stateDoc = DocProvider.of<StateDoc>(context);
    final entries = stateDoc.getBuyerEntries(buyerNumber);
    final sellOutDue = stateDoc.sellOutDue[buyerNumber];
    final hasWorkerPermission = user.hasWorkerPermission;
    return Scaffold(
      appBar: AppBar(title: Text("${buyerInfo.name} Entries"), actions: [
        PopupMenuButton<_Options>(
          itemBuilder: (context) {
            return [
              PopupTile(
                enabled: hasWorkerPermission,
                child: "Sell Stock",
                icon: entryTypeToIcon(EntryType.sell),
                value: _Options.buy,
              ),
              PopupTile(
                enabled: hasWorkerPermission,
                child: "Take Payment",
                icon: entryTypeToIcon(EntryType.sellOutPayment),
                value: _Options.pay,
              ),
              PopupTile(
                enabled: hasWorkerPermission,
                child: "Take Boxes",
                icon: entryTypeToIcon(EntryType.returnBoxes),
                value: _Options.returnBoxes,
              ),
            ];
          },
          onSelected: (option) {
            if (option == _Options.pay) {
              showDialog(
                context: context,
                builder: (context) {
                  return CreateBuyerPaymentEntry(buyer: buyerInfo);
                },
              );
            } else if (option == _Options.buy) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return SellProduct(buyerNumber: buyerNumber);
                }),
              );
            } else if (option == _Options.returnBoxes) {
              showDialog(
                context: context,
                builder: (context) {
                  return CreateReturnBoxesEntry(buyer: buyerInfo);
                },
              );
            }
          },
        ),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          itemBuilder: (context, index) {
            if (index-- == 0) {
              return CardTile(
                title: "Payment Due",
                subtitle: "(left to take)",
                trailing: sellOutDue.payment.toString(),
              );
            }
            if (index-- == 0) {
              return CardTile(
                title: "Boxes Due",
                subtitle: "(left to take)",
                trailing: sellOutDue.boxes.toString(),
              );
            }
            if (index-- == 0) return const HeaderTile(title: "Entries");
            final entry = entries.elementAt(index);
            if (entry is SoldEntry) {
              return SoldEntryTile(entry: entry);
            } else if (entry is SellOutPaymentEntry) {
              return SellOutEntryTile(entry: entry);
            } else if (entry is ReturnBoxesEntry) {
              return ReturnBoxesEntryTile(entry: entry);
            }
            return const SizedBox();
          },
          separatorBuilder: (context, index) {
            if (index < 2) return const SizedBox();
            return const Divider();
          },
          itemCount: entries.length + 3,
        ),
      ),
    );
  }
}
