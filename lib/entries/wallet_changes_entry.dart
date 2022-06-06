import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/entries/entries.dart';
import 'package:distributor/layout/routes.dart';

import 'package:flutter/material.dart';

extension on WalletChangeType {
  bool get isRemoved {
    switch (this) {
      case WalletChangeType.expenses:
        return true;
      case WalletChangeType.salary:
        return true;
      case WalletChangeType.withdrawal:
        return true;
      case WalletChangeType.deposit:
        return false;
    }
  }
}

List<Widget> buildWalletChangesEntry({
  required CompneyDoc? compneyDoc,
  required WalletChangesEntry entry,
  required ProductDoc? productDoc,
}) {
  return [
    const Divider(height: 30),
    HeaderTile(
      title: "Wallet Changes (${entry.walletChangeType.isRemoved ? "-" : "+"})",
      trailing: Text(entry.amount.toString()),
    ),
    HeaderTile(
      title: "Type",
      trailing: Text(entry.walletChangeType.title),
    ),
    if (entry.message.trim().isNotEmpty)
      ListTile(
        title: const Text("Message"),
        subtitle: Text(entry.message),
      ),
  ];
}

class WalletChangesTile extends StatelessWidget {
  const WalletChangesTile({
    Key? key,
    required this.entry,
  }) : super(key: key);

  final WalletChangesEntry entry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: entryTypeToIcon(entry.entryType),
      title: AlternateText(['Wallet ', '-${entry.walletChangeType.title}']),
      subtitle: Text(entry.belongToDate.formateDate()),
      trailing: Text(entry.amount.toString()),
      onTap: () {
        EntryRoute.goTo(context, entry);
      },
    );
  }
}
