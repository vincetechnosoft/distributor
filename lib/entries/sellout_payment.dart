import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/entries/entries.dart';
import 'package:distributor/layout/routes.dart';

import 'package:flutter/material.dart';

List<Widget> buildSellOutPaymentEntry({
  required CompneyDoc? compneyDoc,
  required SellOutPaymentEntry entry,
  required ProductDoc? productDoc,
}) {
  return [
    ListTile(
      title: const Text("Buyer"),
      trailing: Text(
        compneyDoc?.getBuyer(entry.buyerNumber).name ?? entry.buyerNumber,
      ),
    ),
    const Divider(height: 30),
    HeaderTile(
      title: "Wallet Changes (+)",
      trailing: Text(entry.amount.toString()),
    )
  ];
}

class SellOutEntryTile extends StatelessWidget {
  const SellOutEntryTile({
    Key? key,
    required this.entry,
  }) : super(key: key);

  final SellOutPaymentEntry entry;

  @override
  Widget build(BuildContext context) {
    final buyer =
        DocProvider.of<CompneyDoc>(context).getBuyer(entry.buyerNumber);
    return ListTile(
      leading: entryTypeToIcon(entry.entryType),
      title: AlternateText(['Take Payment ', '#${buyer.name}']),
      subtitle: Text(entry.belongToDate.formateDate()),
      trailing: Text(entry.sellOut.amount.toString()),
      onTap: () {
        EntryRoute.goTo(context, entry);
      },
    );
  }
}
