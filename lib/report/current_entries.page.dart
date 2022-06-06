import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/entries/entries.dart';
import 'package:distributor/layout/drawer.dart';
import 'package:distributor/report/entry_filter.dart';
import 'package:flutter/material.dart';

class CurrentEntriesPage extends StatefulWidget {
  const CurrentEntriesPage({Key? key}) : super(key: key);

  @override
  State<CurrentEntriesPage> createState() => _CurrentEntriesPageState();
}

class _CurrentEntriesPageState extends State<CurrentEntriesPage> {
  final entryFilter = EntryFilter();

  @override
  Widget build(BuildContext context) {
    final stateDoc = DocProvider.of<StateDoc>(context);
    final entries = entryFilter(stateDoc.entries);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Current Entries"),
        actions: [
          IconButton(
            onPressed: () async {
              await showEntryFilter(context, entryFilter);
              setState(() {});
            },
            icon: const Icon(Icons.filter_list_rounded),
          )
        ],
      ),
      drawer: const MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          itemBuilder: (context, index) {
            return entryTile(entries.elementAt(index));
          },
          separatorBuilder: (context, index) {
            return const Divider();
          },
          itemCount: entries.length,
        ),
      ),
    );
  }
}

Widget entryTile(Entry entry) {
  if (entry is BoughtEntry) return BoughtEntryTile(entry: entry);
  if (entry is SoldEntry) return SoldEntryTile(entry: entry);
  if (entry is BuyInPaymentEntry) return BuyInEntryTile(entry: entry);
  if (entry is SellOutPaymentEntry) return SellOutEntryTile(entry: entry);
  if (entry is ReturnBoxesEntry) return ReturnBoxesEntryTile(entry: entry);
  if (entry is WastageEntry) return WastageEntryTile(entry: entry);
  if (entry is WalletChangesEntry) return WalletChangesTile(entry: entry);
  return const SizedBox();
}
