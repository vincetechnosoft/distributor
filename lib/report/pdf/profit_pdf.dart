import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/report/pdf/pdf_widgits.dart';
import 'package:distributor/report/report.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:open_file/open_file.dart';

Directory? _tempDir;
Future<void> profitPDF({
  required ProfitSummery summery,
  required ProductDoc productDoc,
  required CompneyDoc compneyDoc,
}) async {
  final dir = _tempDir ??= await getTemporaryDirectory();
  final file = File("${dir.path}/profit.pdf");
  if (await file.exists()) await file.delete();
  final pdf = Document();
  final rows = <TableRow>[];
  for (var entry in summery.profitEntry) {
    if (entry is BoughtEntry) {
      final a = entry.buyIn.amount;
      final name = compneyDoc.seller[entry.sellerNumber].name;
      rows.add(
        TableRow(
          children: [
            pdfTableText(
                "@${name.length > 10 ? "${name.substring(0, 9)}. " : name} -Bought"),
            pdfTableText(
                entry.belongToDate.formateDate(name: true, withYear: false)),
            pdfTableText(a.toString(lead: false, trail: false)),
            pdfTableText(""),
            pdfTableText(a.toString(neg: true, lead: false, trail: false)),
          ],
        ),
      );
    } else if (entry is SoldEntry) {
      final a = entry.sellOut.amount;
      final name = compneyDoc.buyers[entry.buyerNumber].name;
      rows.add(
        TableRow(
          children: [
            pdfTableText(
                "#${name.length > 10 ? "${name.substring(0, 9)}. " : name} -Sold"),
            pdfTableText(
                entry.belongToDate.formateDate(name: true, withYear: false)),
            pdfTableText(""),
            pdfTableText(a.toString(lead: false, trail: false)),
            pdfTableText(a.toString(lead: false, trail: false)),
          ],
        ),
      );
    } else if (entry is WalletChangesEntry &&
        (entry.walletChangeType == WalletChangeType.expenses ||
            entry.walletChangeType == WalletChangeType.salary)) {
      final a = entry.amount;
      rows.add(TableRow(children: [
        pdfTableText("Wallet - ${entry.walletChangeType.name}"),
        pdfTableText(
            entry.belongToDate.formateDate(name: true, withYear: false)),
        pdfTableText(a.toString()),
        pdfTableText(""),
        pdfTableText(a.toString(neg: true)),
      ]));
    }
  }
  final rowInPage = <List<TableRow>>[];
  var i = 0;

  while (true) {
    if (i + 35 > rows.length) {
      rowInPage.add(rows.sublist(i));
      break;
    } else {
      rowInPage.add(rows.sublist(i, i + 35));
      i += 35;
    }
  }
  TableRow header(Context context) => TableRow(
        children: [
          "Entry Type",
          "Date",
          "Outgoing",
          "Incoming",
          "Money",
        ]
            .map((e) => Padding(
                  padding: const EdgeInsets.only(
                    left: 2,
                    top: 2,
                    bottom: 2,
                  ),
                  child: Text(
                    e,
                    style: Theme.of(context).header3,
                  ),
                ))
            .toList(),
      );

  TableRow total(Context context) => TableRow(
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
          pdfTableText(""),
          pdfTableText(
              IntMoney(summery.outgoing).toString(lead: false, trail: false)),
          pdfTableText(
              IntMoney(summery.incoming).toString(lead: false, trail: false)),
          pdfTableText(
              IntMoney(summery.profit).toString(lead: false, trail: false)),
        ],
      );
  var p = 1;
  for (var rowsOfPage in rowInPage) {
    final pageNum = p++;
    pdf.addPage(
      Page(
        build: (context) {
          return Column(children: [
            Text("Page - $pageNum", style: Theme.of(context).header2),
            Table(
              children: [
                header(context),
                ...rowsOfPage,
                if (pageNum == rowInPage.length) total(context),
              ],
              border: TableBorder.all(),
            )
          ]);
        },
        pageFormat: PdfPageFormat.a4,
      ),
    );
  }
  await file.writeAsBytes(await pdf.save());
  await OpenFile.open(file.path);
}
