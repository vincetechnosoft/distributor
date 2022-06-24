import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/entries/entries.dart';
import 'package:distributor/layout/routes.dart';

import 'package:flutter/material.dart';

List<Widget> buildWastageEntry({
  required CompneyDoc? compneyDoc,
  required WastageEntry entry,
  required ProductDoc? productDoc,
}) {
  return [
    const HeaderTile(title: "Inventory (-)"),
    DisplayTable<ItemQun>(
      fixColumn: "Item Name",
      column: const ["Box", "Pack"],
      values: entry.wastedItems,
      rowBuilder: (e) {
        return DisplayRow.str(
          fixedCell:
              productDoc?.getItem(e.id.toString()).name ?? "ProductID: ${e.id}",
          cells: [
            e.quntity.toString(),
            e.pack.toString(),
          ],
        );
      },
    ),
  ];
}

class WastageEntryTile extends StatelessWidget {
  const WastageEntryTile({
    Key? key,
    required this.entry,
  }) : super(key: key);

  final WastageEntry entry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: entryTypeToIcon(entry.entryType),
      title: const AlternateText(['Wasted Stock']),
      subtitle: Text(entry.belongToDate.formateDate()),
      onTap: () {
        EntryRoute.goTo(context, entry);
      },
    );
  }
}
