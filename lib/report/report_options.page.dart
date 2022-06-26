import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/layout/drawer.dart';
import 'package:distributor/report/report.dart';
import 'package:distributor/providers/report.dart';
import 'package:distributor/report/widgets/moneyflow_reort.page.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportOptionsPage extends StatelessWidget {
  const ReportOptionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider(
      create: ReportProvider.init,
      update: ReportProvider.onUpdate,
      child: const _Widgit(),
    );
  }
}

class _Widgit extends StatelessWidget {
  const _Widgit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context);
    final avalableDays = DocProvider.of<CompneyDoc>(context).reportAvalable;
    final entries = reportProvider.entries;
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text("Report Page"),
        actions: [
          IconButton(
            onPressed: reportProvider.showFilterOptions,
            icon: const Icon(Icons.filter_list_rounded),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            if (reportProvider.status == Status.loading)
              const LinearProgressIndicator(),
            ListTile(
              enabled: reportProvider.status != Status.loading,
              leading: const Icon(Icons.date_range),
              title: const Text("Select Month"),
              trailing: DropdownButton<String>(
                items: [
                  DropdownMenuItem(
                    value: currentMonth.month(),
                    child: const Text("Current"),
                  ),
                  ...avalableDays.map(
                    (e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(
                          DateTimeString(e).formateDate(withDate: false),
                        ),
                      );
                    },
                  )
                ],
                value: reportProvider.selectedMonth.month(),
                onChanged: reportProvider.status == Status.loading
                    ? null
                    : reportProvider.onChange,
              ),
            ),
            const Divider(),
            _Card(
              page: MoneyflowReportPage(entries: entries),
              icon: Icons.wallet_rounded,
              name: "Money Flow",
              status: reportProvider.status,
              subtitle: "Net Money Flow from income, expenses etc.,.",
              bgColor: Colors.black,
            ),
            _Card(
              page: ProfitReportPage(entries: entries),
              icon: Icons.currency_rupee_rounded,
              name: "Profit Table",
              status: reportProvider.status,
              subtitle:
                  "Net Profit from stock Transfers, and wallet money expanses",
              bgColor: Colors.blueAccent,
            ),
            _Card(
              page: PurchaseReportPage(entries: entries),
              icon: Icons.shopping_cart_rounded,
              name: "Purchase Table",
              status: reportProvider.status,
              subtitle:
                  "Net Purchases in table, and inventory changes with returned Stock",
              bgColor: Colors.redAccent,
            ),
            _Card(
              page: SellesReportPage(entries: entries),
              icon: Icons.store_mall_directory_rounded,
              name: "Selles Table",
              status: reportProvider.status,
              subtitle:
                  "Net Sells in table, and inventory changes with returned Stock",
              bgColor: Colors.pinkAccent,
            ),
            _Card(
              page: AllEntriesPage(entries: entries),
              icon: Icons.list_rounded,
              name: "All Entries",
              status: reportProvider.status,
              subtitle: "List of All Entries",
              bgColor: Colors.purpleAccent,
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    Key? key,
    required this.subtitle,
    required this.icon,
    required this.name,
    required this.page,
    required this.bgColor,
    required this.status,
  }) : super(key: key);
  final String subtitle;
  final Color bgColor;
  final Status status;
  final Widget page;
  final IconData icon;
  final String name;

  @override
  Widget build(BuildContext context) {
    Widget? trailingWidget;
    switch (status) {
      case Status.loading:
        trailingWidget = const CircularProgressIndicator(color: Colors.white);
        break;
      case Status.error:
        trailingWidget = const Icon(Icons.error, color: Colors.white);
        break;
      case Status.ready:
        trailingWidget = const Icon(Icons.check, color: Colors.white);
        break;
    }
    return Card(
      color: status == Status.ready ? bgColor : Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
        ),
        title: Text(name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        trailing: trailingWidget,
        onTap: () {
          if (status != Status.ready) return;
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return page;
          }));
        },
      ),
    );
  }
}
