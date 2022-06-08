import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/entries/entries.dart';
import 'package:distributor/layout/routes.dart';

import 'package:flutter/material.dart';

List<Widget> buildBoughtEntry({
  required CompneyDoc? compneyDoc,
  required BoughtEntry entry,
  required ProductDoc? productDoc,
}) {
  return [
    ListTile(
      title: const Text("Seller"),
      trailing: Text(
        compneyDoc?.getSeller(entry.sellerNumber).name ??
            "SellerID: ${entry.sellerNumber}",
      ),
    ),
    const Divider(height: 30),
    const HeaderTile(title: "Calculation"),
    DisplayTable<ItemBought>(
      fixColumn: "Item Name",
      column: const ["Rate", "Net Qun", "Net Amount"],
      values: entry.itemBought,
      rowBuilder: (e) {
        return DisplayRow.str(
          fixedCell: productDoc?.getItem(e.id.toString())?.name ??
              "ProductID: ${e.id}",
          cells: [
            e.rate.toString(),
            e.toString(),
            e.amount.toString(),
          ],
        );
      },
      trailing: DisplayRow.str(
        fixedCell: "Total",
        cells: [
          "",
          "",
          entry.buyIn.amount.toString(),
        ],
      ),
    ),
  ];
}

class BoughtEntryTile extends StatelessWidget {
  const BoughtEntryTile({
    Key? key,
    required this.entry,
  }) : super(key: key);

  final BoughtEntry entry;

  @override
  Widget build(BuildContext context) {
    final seller =
        DocProvider.of<CompneyDoc>(context).getSeller(entry.sellerNumber);
    return ListTile(
      leading: entryTypeToIcon(entry.entryType),
      title: AlternateText(['Take Stock ', '@${seller.name}']),
      subtitle: Text(entry.belongToDate.formateDate()),
      trailing: Text(entry.buyIn.amount.toString()),
      onTap: () {
        EntryRoute.goTo(context, entry);
      },
    );
  }
}
