import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/layout/routes.dart';
import 'package:distributor/report/pdf/moneyflow_pdf.dart';

import 'package:flutter/material.dart';

class MoneyflowReportPage extends StatefulWidget {
  const MoneyflowReportPage({Key? key, required this.entries})
      : super(key: key);
  final Iterable<Entry> entries;

  @override
  State<MoneyflowReportPage> createState() => _MoneyflowReportPageState();
}

class _MoneyflowReportPageState extends State<MoneyflowReportPage> {
  Iterable<Entry>? _entries;
  MoneyflowSummery? _data;
  var seeQun = true;

  MoneyflowSummery getData(Iterable<Entry> entries) {
    if (entries == _entries) {
      return _data ??= MoneyflowSummery.from(entries);
    }
    return _data = MoneyflowSummery.from(_entries = entries);
  }

  @override
  Widget build(BuildContext context) {
    final productDoc = DocProvider.of<ProductDoc>(context);
    final compneyDoc = DocProvider.of<CompneyDoc>(context);
    final seller = compneyDoc.seller;
    final buyers = compneyDoc.buyers;
    final data = getData(widget.entries);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Moneyflow Report"),
        actions: [
          IconButton(
            onPressed: () {
              moneyflowPDF(
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
          const HeaderTile(title: "Moneyflow Calculation"),
          DisplayTable<Entry>(
            fixColumn: "Entry Type",
            column: const [
              "Date",
              "Outgoing",
              "Incoming",
              "Money",
            ],
            values: data.moneyTransferEntry,
            onRowTap: (entry) {
              EntryRoute.goTo(context, entry);
            },
            rowBuilder: (entry) {
              if (entry is BuyInPaymentEntry) {
                final a = entry.buyIn.amount;
                final name = seller[entry.buyIn.sellerNumber].name;
                return DisplayRow.str(
                  fixedCell:
                      "Given to @${name.length > 10 ? " ${name.substring(0, 9)}." : name}",
                  cells: [
                    entry.belongToDate.formateDate(name: true, withYear: false),
                    a.toString(),
                    "",
                    a.toString(neg: true),
                  ],
                );
              }
              if (entry is SellOutPaymentEntry) {
                final a = entry.sellOut.amount;
                final name = buyers[entry.sellOut.buyerNumber].name;
                return DisplayRow.str(
                  fixedCell:
                      "Got from #${name.length > 10 ? " ${name.substring(0, 9)}." : name}",
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
                if (entry.walletChangeType == WalletChangeType.deposit) {
                  return DisplayRow.str(
                    fixedCell: "Wallet - ${entry.walletChangeType.name}",
                    cells: [
                      entry.belongToDate
                          .formateDate(name: true, withYear: false),
                      a.toString(neg: true),
                      "",
                      a.toString(),
                    ],
                  );
                }
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

class MoneyflowSummery {
  final List<Entry> moneyTransferEntry = [];
  int outgoing = 0;
  int incoming = 0;

  int get profit => incoming - outgoing;

  MoneyflowSummery.from(Iterable<Entry> entries) {
    for (var entry in entries) {
      if (entry is WalletChangesEntry) {
        if (entry.walletChangeType == WalletChangeType.deposit) {
          incoming += entry.amount.money;
        } else {
          outgoing += entry.amount.money;
        }
        moneyTransferEntry.add(entry);
      } else if (entry is BuyInPaymentEntry) {
        outgoing += entry.buyIn.amount.money;
        moneyTransferEntry.add(entry);
      } else if (entry is SellOutPaymentEntry) {
        incoming += entry.sellOut.amount.money;
        moneyTransferEntry.add(entry);
      }
    }
  }
}
