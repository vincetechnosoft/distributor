import 'package:distributor/entries/entries.dart';
import 'package:distributor/layout/routes.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';

import 'package:flutter/material.dart';

List<Widget> buildSoldEntry({
  required CompneyDoc? compneyDoc,
  required SoldEntry entry,
  required ProductDoc? productDoc,
}) {
  return [
    ListTile(
      title: const Text("Buyer"),
      trailing: Text(
        compneyDoc?.buyers[entry.buyerNumber].name ?? entry.buyerNumber,
      ),
    ),
    const Divider(height: 30),
    const HeaderTile(title: "Calculation"),
    DisplayTable<ItemSold>(
      fixColumn: "Item Name",
      column: const ["Rate (-Dis.)", "Net Qun", "Net Amount"],
      values: entry.itemSold,
      rowBuilder: (e) {
        return DisplayRow.str(
          fixedCell:
              productDoc?.getItem(e.id.toString()).name ?? "ProductID: ${e.id}",
          cells: [
            '${e.rate.toString(trail: false)} ( -${e.discountApplyed.toString(trail: false, lead: false)} )',
            e.toString(),
            e.amount.toString(),
          ],
        );
      },
      trailing: DisplayRow.str(
        fixedCell: "Total",
        cells: [
          "",
          "Box: ${entry.dueBoxes.boxes}",
          entry.sellOut.amount.toString(),
        ],
      ),
    ),
  ];
}

class SoldEntryTile extends StatelessWidget {
  const SoldEntryTile({
    Key? key,
    required this.entry,
  }) : super(key: key);

  final SoldEntry entry;

  @override
  Widget build(BuildContext context) {
    final buyer = DocProvider.of<CompneyDoc>(context).buyers[entry.buyerNumber];
    return ListTile(
      leading: entryTypeToIcon(entry.entryType),
      title: AlternateText(['Give Stock ', '#${buyer.name}']),
      subtitle: Text(entry.belongToDate.formateDate()),
      trailing: Text(entry.sellOut.amount.toString()),
      onTap: () {
        EntryRoute.goTo(context, entry);
      },
    );
  }
}
