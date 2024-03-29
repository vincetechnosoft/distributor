import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/entries/entries.dart';
import 'package:distributor/layout/routes.dart';

import 'package:flutter/material.dart';

List<Widget> buildBuyInPaymentEntry({
  required CompneyDoc? compneyDoc,
  required BuyInPaymentEntry entry,
  required ProductDoc? productDoc,
}) {
  return [
    ListTile(
      title: const Text("Seller"),
      trailing: Text(
        compneyDoc?.seller[entry.buyIn.sellerNumber].name ??
            "SellerID: ${entry.buyIn.sellerNumber}",
      ),
    ),
    const Divider(height: 30),
    HeaderTile(
      title: "Wallet Changes (-)",
      trailing: Text(entry.buyIn.amount.toString()),
    )
  ];
}

class BuyInEntryTile extends StatelessWidget {
  const BuyInEntryTile({
    Key? key,
    required this.entry,
  }) : super(key: key);

  final BuyInPaymentEntry entry;

  @override
  Widget build(BuildContext context) {
    final seller =
        DocProvider.of<CompneyDoc>(context).seller[entry.buyIn.sellerNumber];
    return ListTile(
      leading: entryTypeToIcon(entry.entryType),
      title: AlternateText(['Give Payment ', '@${seller.name}']),
      subtitle: Text(entry.belongToDate.formateDate()),
      trailing: Text(entry.buyIn.amount.toString()),
      onTap: () {
        EntryRoute.goTo(context, entry);
      },
    );
  }
}
