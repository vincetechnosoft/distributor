import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/report/pdf/pdf_widgits.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:open_file/open_file.dart';

Directory? _tempDir;
Future<void> sellesPDF({
  required Iterable<Entry> entries,
  required ProductDoc productDoc,
  required CompneyDoc compneyDoc,
}) async {
  final dir = _tempDir ??= await getTemporaryDirectory();
  final file = File("${dir.path}/buyers.pdf");
  if (await file.exists()) await file.delete();
  final pdf = Document();
  final buyerEntry = <String, List<SoldEntry>>{};
  for (var entry in entries) {
    if (entry is! SoldEntry) continue;
    (buyerEntry[entry.buyerNumber] ??= []).add(entry);
  }
  for (var buyer in buyerEntry.entries) {
    _createBuyersBoughtPage(
      pdf,
      buyer.key,
      compneyDoc.buyers[buyer.key].name,
      buyer.value,
      productDoc,
    );
  }
  await file.writeAsBytes(await pdf.save());
  await OpenFile.open(file.path);
}

class _Stock {
  int q = 0;
  int p = 0;

  @override
  String toString() {
    if (p == 0) {
      if (q == 0) return "";
      return IntQuntity(q).toString();
    }
    return "${IntQuntity(q)}, ${IntQuntity(p)}";
  }
}

void _createBuyersBoughtPage(
  Document pdf,
  String phoneNumber,
  String name,
  Iterable<SoldEntry> entries,
  ProductDoc productData,
) {
  final data = <String, Map<int, _Stock>>{};
  final total = <String, int>{};
  for (var entry in entries) {
    final date = entry.belongToDate.formateDate().substring(0, 2);
    total[date] = (total[date] ?? 0) + entry.sellOut.amount.money;
    final stocks = data[date] ??= {};
    for (var item in entry.itemSold) {
      final stock = stocks[item.id] ??= _Stock();
      stock.q += item.quntity.quntity;
      stock.p += item.pack.quntity;
    }
  }
  final products = productData.items;
  final dateColl = <List<String>>[];
  for (var i = 1; i < 32; i++) {
    if (i % 7 == 1) {
      dateColl.add(["$i".padLeft(2, "0")]);
    } else {
      dateColl.last.add("$i".padLeft(2, "0"));
    }
  }
  for (var d in dateColl) {
    pdf.addPage(Page(
      pageFormat: PdfPageFormat.a4,
      margin: const EdgeInsets.all(5),
      build: (context) {
        return Column(
          children: [
            Text("$name - $phoneNumber", style: Theme.of(context).header2),
            Table(
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 2,
                        top: 2,
                        bottom: 2,
                      ),
                      child: Text(
                        "May 2022",
                        style: Theme.of(context).header3,
                      ),
                    ),
                    ...d.map(pdfTableText),
                  ],
                ),
                ...products.map(
                  (product) => TableRow(
                    children: [
                      pdfTableText(product.name),
                      ...d.map(
                        (date) => SizedBox(
                          width: 50,
                          child:
                              pdfTableText("${data[date]?[product.id] ?? ""}"),
                        ),
                      ),
                    ],
                  ),
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 2,
                        top: 2,
                        bottom: 2,
                      ),
                      child: Text(
                        "Total (in Rs)",
                        style: Theme.of(context).header3,
                      ),
                    ),
                    ...d.map((e) => pdfTableText(
                        IntMoney(((total[e] ?? 0) ~/ 1000) * 1000)
                            .toString(lead: false, trail: false))),
                  ],
                ),
              ],
              border: TableBorder.all(),
            ),
          ],
        );
      },
    ));
  }
}
