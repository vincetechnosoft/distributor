import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/report/pdf/purchase_pdf.dart';
import 'package:flutter/material.dart';

class PurchaseReportPage extends StatefulWidget {
  const PurchaseReportPage({Key? key, required this.entries}) : super(key: key);
  final Iterable<Entry> entries;

  @override
  State<PurchaseReportPage> createState() => _PurchaseReportPageState();
}

class _PurchaseReportPageState extends State<PurchaseReportPage> {
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
    final productDoc = DocProvider.of<ProductDoc>(context);
    final compneyDoc = DocProvider.of<CompneyDoc>(context);
    final getProduct = productDoc.getItem;
    final seller = compneyDoc.seller;
    final data = getData(widget.entries);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchase Report"),
        actions: [
          IconButton(
            onPressed: () {
              purchasePDF(
                entries: widget.entries,
                productDoc: productDoc,
                compneyDoc: compneyDoc,
              );
            },
            icon: const Icon(Icons.picture_as_pdf_rounded),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            HeaderTile(
              title: "Purchase summery",
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
              column: data.sellerNumbersUsed.map((e) => seller[e].name),
              values: data.productIDsUsed,
              rowBuilder: (productID) {
                final data1 = data.data[productID];
                final product = getProduct("$productID");
                final name = product.name;
                return DisplayRow(
                  fixedCell: name,
                  cells: data.sellerNumbersUsed.map(
                    (sellerNumber) {
                      final data2 = data1?[sellerNumber];
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
                                  "@${seller[sellerNumber].name}"
                                ]),
                                content: DisplayTable<MapEntry<int, _Bought>>(
                                  fixColumn: "Rate",
                                  column: const ["Box", "Pack", "Amount"],
                                  values: data2.data.entries,
                                  rowBuilder: (item) {
                                    return DisplayRow.str(
                                      fixedCell: IntMoney(item.key).toString(),
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
            const HeaderTile(title: "Inventory Changes ( + )"),
            DisplayTable(
              fixColumn: "Product Name",
              column: data.sellerNumbersUsed.map((e) => seller[e].name),
              values: data.productIDsUsed,
              rowBuilder: (productID) {
                final product = getProduct("$productID");
                final data1 = data.data[productID];
                final name = product.name;
                return DisplayRow.str(
                  fixedCell: name,
                  cells: data.sellerNumbersUsed.map(
                    (buyerNumber) {
                      final data2 = data1?[buyerNumber];
                      final initQun = data2?.initQun;
                      return "${initQun?.quntity ?? 0}, ${initQun?.pack ?? 0}";
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

class _Bought {
  int quntity = 0;
  int pack = 0;
  int amount = 0;

  _Bought();

  void add(ItemQun itemQun, int a) {
    quntity += itemQun.quntity.quntity;
    pack += itemQun.pack.quntity;
    amount += a;
  }
}

class _NetBought {
  /// ! rate => bought;
  Map<int, _Bought> data = {};
  final int id;
  _NetBought(this.id);
  var amount = 0;
  var quntity = 0;
  var pack = 0;

  ItemQun get initQun => ItemQun(id: id, quntity: quntity, pack: pack);

  add(ItemBought itemBought) {
    final a = itemBought.amount;
    (data[itemBought.rate.money] ??= _Bought()).add(itemBought, a.money);
    amount += a.money;
    quntity += itemBought.quntity.quntity;
    pack += itemBought.pack.quntity;
  }
}

class _Summery {
  /// ! productID => sellerNumber => netBought;
  final Map<int, Map<String, _NetBought>> data = {};
  late final List<int> productIDsUsed;
  late final List<String> sellerNumbersUsed;

  _Summery.from(Iterable<Entry> entries) {
    final productIDs = <int>{};
    final sellerNumbers = <String>{};
    for (var entry in entries) {
      if (entry is! BoughtEntry) continue;
      sellerNumbers.add(entry.sellerNumber);
      for (var item in entry.itemBought) {
        productIDs.add(item.id);
        ((data[item.id] ??= {})[entry.sellerNumber] ??= _NetBought(item.id))
            .add(item);
      }
    }
    productIDsUsed = productIDs.toList()..sort();
    sellerNumbersUsed = sellerNumbers.toList()..sort();
  }
}
