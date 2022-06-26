import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/layout/routes.dart';
import 'package:distributor/report/pdf/profit_pdf.dart';

import 'package:flutter/material.dart';

class ProfitReportPage extends StatefulWidget {
  const ProfitReportPage({Key? key, required this.entries}) : super(key: key);
  final Iterable<Entry> entries;

  @override
  State<ProfitReportPage> createState() => _ProfitReportPageState();
}

class _ProfitReportPageState extends State<ProfitReportPage> {
  Iterable<Entry>? _entries;
  ProfitSummery? _data;
  var seeQun = true;

  ProfitSummery getData(Iterable<Entry> entries, ProductDoc productDoc) {
    if (entries == _entries) {
      return _data ??= ProfitSummery.from(entries, productDoc);
    }
    return _data = ProfitSummery.from(_entries = entries, productDoc);
  }

  @override
  Widget build(BuildContext context) {
    final compneyDoc = DocProvider.of<CompneyDoc>(context);
    final productDoc = DocProvider.of<ProductDoc>(context);
    final seller = compneyDoc.seller;
    final buyers = compneyDoc.buyers;
    final data = getData(widget.entries, productDoc);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profit Report"),
        actions: [
          IconButton(
            onPressed: () {
              profitPDF(
                summery: data,
                productDoc: productDoc,
                compneyDoc: compneyDoc,
              );
            },
            icon: const Icon(Icons.picture_as_pdf_rounded),
          )
        ],
      ),
      body: ListView(
        children: [
          const HeaderTile(title: "Profit Calculation"),
          DisplayTable<Entry>(
            fixColumn: "Entry Type",
            column: const [
              "Date",
              "Outgoing",
              "Incoming",
              "Money",
            ],
            values: data.profitEntry,
            onRowTap: (entry) {
              EntryRoute.goTo(context, entry);
            },
            rowBuilder: (entry) {
              if (entry is BoughtEntry) {
                final a = entry.buyIn.amount;
                final name = seller[entry.sellerNumber].name;
                return DisplayRow.str(
                  fixedCell:
                      "@${name.length > 10 ? "${name.substring(0, 9)}. " : name} -Bought",
                  cells: [
                    entry.belongToDate.formateDate(name: true, withYear: false),
                    a.toString(),
                    "",
                    a.toString(neg: true),
                  ],
                );
              }
              if (entry is SoldEntry) {
                final a = entry.sellOut.amount;
                final name = buyers[entry.buyerNumber].name;
                return DisplayRow.str(
                  fixedCell:
                      "#${name.length > 10 ? "${name.substring(0, 9)}. " : name} -Sold",
                  cells: [
                    entry.belongToDate.formateDate(name: true, withYear: false),
                    "",
                    a.toString(),
                    a.toString(),
                  ],
                );
              }
              if (entry is WalletChangesEntry) {
                final a = entry.amount;
                return DisplayRow.str(
                  fixedCell: "Wallet - ${entry.walletChangeType.name}",
                  cells: [
                    entry.belongToDate.formateDate(name: true, withYear: false),
                    a.toString(),
                    "",
                    a.toString(neg: true),
                  ],
                );
              }
              return DisplayRow.str(
                fixedCell: "--",
                cells: ["--", "--", "--", "--"],
              );
            },
            trailing: DisplayRow.str(
              fixedCell: "Total",
              cells: [
                "",
                IntMoney(data.outgoing).toString(),
                IntMoney(data.incoming).toString(),
                IntMoney(data.profit).toString(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stock {
  int _q = 0;
  int _p = 0;

  void add(ItemBought itemBought) {
    _q += itemBought.quntity.quntity;
    _p += itemBought.pack.quntity;
  }

  void remove(ItemSold itemSold) {
    _q -= itemSold.quntity.quntity;
    _p -= itemSold.pack.quntity;
  }
}

class ProfitSummery {
  int outgoing = 0;
  int incoming = 0;

  int get profit => incoming - outgoing;
  final List<Entry> profitEntry = [];

  ProfitSummery.from(Iterable<Entry> entries, ProductDoc productDoc) {
    final inventory = <int, _Stock>{};
    for (var entry in entries) {
      if (entry is BoughtEntry) {
        outgoing += entry.buyIn.amount.money;
        profitEntry.add(entry);
        for (var e in entry.itemBought) {
          (inventory[e.id] ??= _Stock()).add(e);
        }
      } else if (entry is SoldEntry) {
        incoming += entry.sellOut.amount.money;
        profitEntry.add(entry);
        for (var e in entry.itemSold) {
          (inventory[e.id] ??= _Stock()).remove(e);
        }
      } else if (entry is WalletChangesEntry) {
        if (entry.walletChangeType == WalletChangeType.salary ||
            entry.walletChangeType == WalletChangeType.expenses) {
          outgoing += entry.amount.money;
          profitEntry.add(entry);
        }
      }
    }
    final remainingStocks = <ItemSold>[];
    final requiredStoks = <ItemBought>[];
    for (var e in inventory.entries) {
      final product = productDoc.getItem(e.key.toString());
      final stock = e.value;
      final itemSold = ItemSold(
        id: product.id,
        quntity: stock._q,
        pack: stock._p,
        discountApplyed: product.defaultDiscount,
        rate: product.rate,
      );
      if (itemSold.amount.money < 0) {
        requiredStoks.add(
          ItemBought(
            id: product.id,
            quntity: -stock._q,
            pack: -stock._p,
            rate: product.defaultBoughtRate,
          ),
        );
      } else {
        remainingStocks.add(itemSold);
      }
    }
    if (requiredStoks.isNotEmpty) {
      profitEntry.add(
        BoughtEntry(sellerNumber: "Required Stock", itemBought: requiredStoks),
      );
    }
    if (remainingStocks.isNotEmpty) {
      profitEntry.add(
        SoldEntry(buyerNumber: "Remaning Stock", itemSold: remainingStocks),
      );
    }
  }
}
