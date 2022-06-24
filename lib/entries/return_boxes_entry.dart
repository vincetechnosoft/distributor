import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/entries/entries.dart';
import 'package:distributor/layout/routes.dart';

import 'package:flutter/material.dart';

List<Widget> buildReturnBoxesEntry({
  required CompneyDoc? compneyDoc,
  required ReturnBoxesEntry entry,
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
    HeaderTile(
      title: "Boxes Reurned (+)",
      trailing: Text(entry.boxes.toString()),
    )
  ];
}

class ReturnBoxesEntryTile extends StatelessWidget {
  const ReturnBoxesEntryTile({
    Key? key,
    required this.entry,
  }) : super(key: key);

  final ReturnBoxesEntry entry;

  @override
  Widget build(BuildContext context) {
    final buyer = DocProvider.of<CompneyDoc>(context).buyers[entry.buyerNumber];
    return ListTile(
      leading: entryTypeToIcon(entry.entryType),
      title: AlternateText(['Take Boxes ', '#${buyer.name}']),
      subtitle: Text(entry.belongToDate.formateDate()),
      trailing: Text(entry.boxes.toString()),
      onTap: () {
        EntryRoute.goTo(context, entry);
      },
    );
  }
}
