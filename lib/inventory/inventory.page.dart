import 'package:distributor/auth/auth.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/entries/entries.dart';
import 'package:distributor/home/widgets/edit_product.dart';
import 'package:distributor/inventory/create/wallet_changes_entry.page.dart';
import 'package:distributor/layout/drawer.dart';
import 'package:distributor/layout/routes.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _Options { addItem, stockWastage, expenses, salary, withdrawal, deposit }

class InventoryPage extends StatelessWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyAuthUser>(context);
    final productDoc = DocProvider.of<ProductDoc>(context);
    final stateDoc = DocProvider.of<StateDoc>(context);
    final items = productDoc.items;
    final getQuntityOf = stateDoc.getQuntityOf;
    final walletMoney = stateDoc.walletMoney;
    final boxes = stateDoc.boxes;
    final hasOwnerPermission = user.hasOwnerPermission;
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text("Inventory"),
        actions: [
          PopupMenuButton<_Options>(
            itemBuilder: (context) {
              return [
                PopupTile(
                  enabled: hasOwnerPermission,
                  child: "New Product",
                  value: _Options.addItem,
                  icon: const Icon(Icons.add),
                ),
                PopupTile(
                  enabled: hasOwnerPermission,
                  child: "Stock Wastage",
                  value: _Options.stockWastage,
                  icon: entryTypeToIcon(EntryType.wasted),
                ),
                const PopupMenuDivider(),
                PopupTile(
                  enabled: hasOwnerPermission,
                  child: "Make Expenses",
                  value: _Options.expenses,
                  icon: entryTypeToIcon(EntryType.wallet),
                ),
                PopupTile(
                  enabled: hasOwnerPermission,
                  child: "Give Salary",
                  value: _Options.salary,
                  icon: entryTypeToIcon(EntryType.wallet),
                ),
                PopupTile(
                  enabled: hasOwnerPermission,
                  child: "Withdraw Money",
                  value: _Options.withdrawal,
                  icon: entryTypeToIcon(EntryType.wallet),
                ),
                PopupTile(
                  enabled: hasOwnerPermission,
                  child: "Deposit Money",
                  value: _Options.deposit,
                  icon: entryTypeToIcon(EntryType.wallet),
                ),
              ];
            },
            onSelected: (o) => _onSelectOption(o, context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            const HeaderTile(title: "Current Wallet"),
            CardTile(
              title: "Wallet Money",
              trailing: walletMoney.toString(),
            ),
            CardTile(
              title: "Boxes",
              trailing: boxes.toString(),
            ),
            const Divider(height: 30),
            const HeaderTile(title: "Current Inventory"),
            DisplayTable<Product>(
              fixColumn: "Item Name",
              column: const ["Box", "Rate (-Disc.)", "Amount"],
              values: items,
              rowBuilder: (e) {
                final inv = getQuntityOf("${e.id}");
                final itemSold = ItemSold(
                  id: e.id,
                  quntity: inv.quntity.quntity,
                  pack: inv.pack.quntity,
                  discountApplyed: e.defaultDiscount,
                  rate: e.rate,
                );
                return DisplayRow.str(
                  fixedCell: e.name,
                  cells: [
                    inv.toString(),
                    "${e.rate} ( -${e.defaultDiscount.toString(lead: false, trail: false)} )",
                    itemSold.amount.toString(),
                  ],
                );
              },
              trailing: items.isEmpty
                  ? null
                  : DisplayRow.str(fixedCell: "Total", cells: [
                      "",
                      "",
                      IntMoney(items.map((e) {
                        final inv = getQuntityOf("${e.id}");
                        final itemSold = ItemSold(
                          id: e.id,
                          quntity: inv.quntity.quntity,
                          pack: inv.pack.quntity,
                          discountApplyed: e.defaultDiscount,
                          rate: e.rate,
                        );
                        return itemSold.amount.money;
                      }).reduce((value, element) => value + element)).toString()
                    ]),
            ),
          ],
        ),
      ),
    );
  }

  void _onSelectOption(_Options option, BuildContext context) {
    switch (option) {
      case _Options.addItem:
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const ItemPage(productID: null);
        }));
        break;
      case _Options.stockWastage:
        SecondaryRoute.goTo(context, SecondaryPage.inventoryWastage);
        break;
      case _Options.expenses:
        showDialog(
          context: context,
          builder: (context) {
            return const CreateWalletChangesEntry(WalletChangeType.expenses);
          },
        );
        break;
      case _Options.salary:
        showDialog(
          context: context,
          builder: (context) {
            return const CreateWalletChangesEntry(WalletChangeType.salary);
          },
        );
        break;
      case _Options.withdrawal:
        showDialog(
          context: context,
          builder: (context) {
            return const CreateWalletChangesEntry(WalletChangeType.withdrawal);
          },
        );
        break;
      case _Options.deposit:
        showDialog(
          context: context,
          builder: (context) {
            return const CreateWalletChangesEntry(WalletChangeType.deposit);
          },
        );
        break;
    }
  }
}
