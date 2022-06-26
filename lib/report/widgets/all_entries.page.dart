import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/report/current_entries.page.dart';

import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

class AllEntriesPage extends StatelessWidget {
  const AllEntriesPage({Key? key, required this.entries}) : super(key: key);
  final Iterable<Entry> entries;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Entries")),
      body: GroupedListView<Entry, _TimeStamp>(
        elements: entries.toList(),
        groupBy: (entry) => _TimeStamp(entry.belongToDate),
        groupSeparatorBuilder: (groupByValue) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Colors.deepPurpleAccent,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    groupByValue.date,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
        itemBuilder: (context, entry) => entryTile(entry),
        useStickyGroupSeparators: true,
        floatingHeader: true,
      ),
    );
  }
}

class _TimeStamp with Comparable<_TimeStamp> {
  final String date;
  final DateTimeString timestamp;
  _TimeStamp(this.timestamp) : date = timestamp.formateDate();

  @override
  bool operator ==(Object other) => other is _TimeStamp && other.date == date;

  @override
  int get hashCode => date.hashCode;

  @override
  int compareTo(_TimeStamp other) {
    return timestamp.compareTo(other.timestamp);
  }
}
