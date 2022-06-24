import 'package:bmi_b2b_package/bmi_b2b_package.dart';

import 'package:flutter/material.dart';

class SellesReportPage extends StatefulWidget {
  const SellesReportPage({Key? key, required this.entries}) : super(key: key);
  final Iterable<Entry> entries;

  @override
  State<SellesReportPage> createState() => _SellesReportPageState();
}

class _SellesReportPageState extends State<SellesReportPage> {
  Iterable<Entry>? _summerizeReport;
  _Summery? _data;
  var seeQun = true;

  _Summery getData(Iterable<Entry> entries) {
    if (entries == _summerizeReport) {
      return _data ??= _Summery.from(entries);
    }
    return _data = _Summery.from(_summerizeReport = entries);
  }

  @override
  Widget build(BuildContext context) {
    final getProduct = DocProvider.of<ProductDoc>(context).getItem;
    final buyers = DocProvider.of<CompneyDoc>(context).buyers;
    final data = getData(widget.entries);
    return Scaffold(
      appBar: AppBar(title: const Text("Sells Report")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            HeaderTile(
              title: "Sells summery",
              trailing: IconButton(
                onPressed: () {
                  setState(() {
                    seeQun = !seeQun;
                  });
                },
                icon: Combine2Icons(
                  subMain: seeQun
                      ? Icons.currency_rupee_rounded
                      : Icons.shopping_cart,
                  main: Icons.undo_rounded,
                  alignmentDirectional: AlignmentDirectional.topEnd,
                ),
              ),
            ),
            DisplayTable(
              fixColumn: "Product Name",
              column: data.buyerNumbersUsed.map((e) => buyers[e].name),
              values: data.productIDsUsed,
              rowBuilder: (productID) {
                final data1 = data.data[productID];
                final product = getProduct("$productID");
                final name = product.name;
                return DisplayRow(
                  fixedCell: name,
                  cells: data.buyerNumbersUsed.map(
                    (buyerNumber) {
                      final data2 = data1?[buyerNumber];
                      return DisplayCell(
                        data2 == null
                            ? "-"
                            : seeQun
                                ? "${IntQuntity(data2.quntity)}, ${IntQuntity(data2.pack)}"
                                : IntMoney(data2.amount).toString(),
                        () {
                          if (data2 == null) return;
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: AlternateText([
                                  "$name  ",
                                  "#${buyers[buyerNumber].name}"
                                ]),
                                content: DisplayTable<MapEntry<String, _Sold>>(
                                  fixColumn: "Rate (-Disc.)",
                                  column: const ["Box", "Pack", "Amount"],
                                  values: data2.data.entries,
                                  rowBuilder: (item) {
                                    final a = item.key
                                        .split("-")
                                        .map((e) => toInt(e));
                                    return DisplayRow.str(
                                      fixedCell:
                                          "${IntMoney(a.first)}( ${IntMoney(-a.last).toString(lead: false, trail: false)})",
                                      cells: [
                                        IntQuntity(item.value.quntity)
                                            .toString(),
                                        IntQuntity(item.value.pack).toString(),
                                        IntMoney(item.value.amount).toString(),
                                      ],
                                    );
                                  },
                                  trailing: DisplayRow.str(
                                    fixedCell: "Total",
                                    cells: [
                                      IntQuntity(data2.quntity).toString(),
                                      IntQuntity(data2.pack).toString(),
                                      IntMoney(data2.amount).toString(),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
            const HeaderTile(title: "Inventory Changes ( - )"),
            DisplayTable(
              fixColumn: "Product Name",
              column: data.buyerNumbersUsed.map((e) => buyers[e].name),
              values: data.productIDsUsed,
              rowBuilder: (productID) {
                final product = getProduct("$productID");
                final data1 = data.data[productID];
                final name = product.name;
                return DisplayRow.str(
                  fixedCell: name,
                  cells: data.buyerNumbersUsed.map(
                    (buyerNumber) {
                      final data2 = data1?[buyerNumber];
                      final initQun = data2?.initQun;
                      return "${(initQun?.quntity ?? 0)}, ${(initQun?.pack ?? 0)}";
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}

class _Sold {
  int quntity = 0;
  int pack = 0;
  int amount = 0;

  _Sold();

  void add(ItemQun itemQun, int a) {
    quntity += itemQun.quntity.quntity;
    pack += itemQun.pack.quntity;
    amount += a;
  }
}

class _NetSold {
  /// ! "$rate-$disc" => sold;
  Map<String, _Sold> data = {};
  final int id;
  _NetSold(this.id);
  var amount = 0;
  var quntity = 0;
  var pack = 0;

  ItemQun get initQun => ItemQun(id: id, quntity: quntity, pack: pack);

  add(ItemSold itemBought) {
    final a = itemBought.amount;
    (data["${itemBought.rate.money}-${itemBought.discountApplyed.money}"] ??=
            _Sold())
        .add(itemBought, a.money);
    amount += a.money;
    quntity += itemBought.quntity.quntity;
    pack += itemBought.pack.quntity;
  }
}

class _Summery {
  /// ! productID => buyerNumber => netSold;
  final Map<int, Map<String, _NetSold>> data = {};
  late final List<int> productIDsUsed;
  late final List<String> buyerNumbersUsed;

  _Summery.from(Iterable<Entry> entries) {
    final productIDs = <int>{};
    final buyerNumbers = <String>{};
    for (var entry in entries) {
      if (entry is! SoldEntry) continue;
      buyerNumbers.add(entry.buyerNumber);
      for (var item in entry.itemSold) {
        productIDs.add(item.id);
        ((data[item.id] ??= {})[entry.buyerNumber] ??= _NetSold(item.id))
            .add(item);
      }
    }
    productIDsUsed = productIDs.toList()..sort();
    buyerNumbersUsed = buyerNumbers.toList()..sort();
  }
}
