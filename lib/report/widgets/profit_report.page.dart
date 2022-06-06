import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/layout/routes.dart';

import 'package:flutter/material.dart';

class ProfitReportPage extends StatefulWidget {
  const ProfitReportPage({Key? key, required this.entries}) : super(key: key);
  final Iterable<Entry> entries;

  @override
  State<ProfitReportPage> createState() => _ProfitReportPageState();
}

class _ProfitReportPageState extends State<ProfitReportPage> {
  Iterable<Entry>? _entries;
  _Summery? _data;
  var seeQun = true;

  _Summery getData(Iterable<Entry> entries) {
    if (entries == _entries) {
      return _data ??= _Summery.from(entries);
    }
    return _data = _Summery.from(_entries = entries);
  }

  @override
  Widget build(BuildContext context) {
    final compneyDoc = DocProvider.of<CompneyDoc>(context);
    final getSeller = compneyDoc.getSeller;
    final getBuyer = compneyDoc.getBuyer;
    final data = getData(widget.entries);
    final totalProfit = data.totalProfit;
    return Scaffold(
      appBar: AppBar(title: const Text("Profit Report")),
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
            displaySelectRow: DisplaySelectRow(
              selected: data.selectedProfitEntries,
              onSelectChange: (entry, select) {
                setState(() {
                  if (select) {
                    data.selectedProfitEntries.add(entry);
                  } else {
                    data.selectedProfitEntries.remove(entry);
                  }
                });
              },
            ),
            onRowTap: (entry) {
              EntryRoute.goTo(context, entry);
            },
            rowBuilder: (entry) {
              if (entry is BoughtEntry) {
                final a = entry.buyIn.amount;
                final name = getSeller(entry.sellerID).name;
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
                final name = getBuyer(entry.buyerNumber).name;
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
                if (entry.walletChangeType == WalletChangeType.salary) {
                  final a = entry.amount;
                  return DisplayRow.str(
                    fixedCell: "Wallet - Salary",
                    cells: [
                      entry.belongToDate
                          .formateDate(name: true, withYear: false),
                      a.toString(),
                      "",
                      a.toString(neg: true),
                    ],
                  );
                } else if (entry.walletChangeType ==
                    WalletChangeType.expenses) {
                  final a = entry.amount;
                  return DisplayRow.str(
                    fixedCell: "Wallet - Expenses",
                    cells: [
                      entry.belongToDate
                          .formateDate(name: true, withYear: false),
                      a.toString(),
                      "",
                      a.toString(neg: true),
                    ],
                  );
                }
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
                IntMoney(totalProfit.outgoing).toString(),
                IntMoney(totalProfit.incoming).toString(),
                IntMoney(totalProfit.profit).toString(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Total {
  int outgoing = 0;
  int incoming = 0;

  int get profit => incoming - outgoing;
}

class _Summery {
  final List<Entry> moneyTransferEntry = [];
  final List<WalletChangesEntry> moneyExpensesEntry = [];
  final List<Entry> stockTransferEntry = [];
  final Set<Entry> selectedProfitEntries = {};

  List<Entry> get profitEntry => [
        ...stockTransferEntry,
        ...moneyExpensesEntry.where((e) =>
            e.walletChangeType == WalletChangeType.salary ||
            e.walletChangeType == WalletChangeType.expenses)
      ];

  _Total get totalProfit {
    var a = _Total();
    for (var e in selectedProfitEntries) {
      if (e is BoughtEntry) a.outgoing += e.buyIn.amount.money;
      if (e is SoldEntry) a.incoming += e.sellOut.amount.money;
      if (e is WalletChangesEntry) {
        if (e.walletChangeType == WalletChangeType.salary ||
            e.walletChangeType == WalletChangeType.expenses) {
          a.outgoing += e.amount.money;
        }
      }
    }
    return a;
  }

  _Summery.from(Iterable<Entry> entries) {
    for (var entry in entries) {
      if (entry is BoughtEntry || entry is SoldEntry) {
        stockTransferEntry.add(entry);
      } else if (entry is WalletChangesEntry) {
        moneyExpensesEntry.add(entry);
      } else if (entry is BuyInPaymentEntry || entry is SellOutPayment) {
        moneyTransferEntry.add(entry);
      }
    }
    selectedProfitEntries.addAll(profitEntry);
  }
}
