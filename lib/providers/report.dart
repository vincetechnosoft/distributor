import 'dart:io' as io;
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/main.dart';
import 'package:distributor/providers/location.dart';
import 'package:distributor/report/entry_filter.dart';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';

enum Status { loading, error, ready }

DateTimeString get currentMonth {
  return DateTimeString.fromDateTime(DateTime.now());
}

extension Month on DateTimeString {
  String month([bool inName = false]) {
    return formateDate(name: inName, withDate: false);
  }
}

class ReportProvider with ChangeNotifier {
  final _compneyID = LocationProvider.inUse!.compneyID!;
  final _ref = FirebaseStorage.instance.ref("DISTRIBUTOR-REPORTS");
  final _dio = Dio();
  final _entryFilter = EntryFilter();
  final BuildContext context;
  var _selectedMonth = currentMonth;
  var _status = Status.loading;
  var _recive = .0;
  List<Entry>? _entries;

  ReportProvider.init(this.context) {
    _inUse = this;
  }

  static ReportProvider? _inUse;
  static ReportProvider? get inUse => _inUse;

  List<Entry> get entries => _entryFilter(_entries ?? []).toList()
    ..sort((a, b) => a.belongToDate.compareTo(b.belongToDate));

  DateTimeString get selectedMonth => _selectedMonth;
  Status get status => _status;
  double get recive => _recive;

  factory ReportProvider.onUpdate(
    BuildContext context,
    DocProvider<StateDoc> stateDoc,
    ReportProvider? previous,
  ) {
    previous ??= ReportProvider.init(context);
    if (previous._selectedMonth.month() == currentMonth.month()) {
      previous._entries = stateDoc.doc?.entries.toList();
      previous._status = Status.ready;
      previous.notifyListeners();
    }
    return previous;
  }

  void showFilterOptions() async {
    await showEntryFilter(context, _entryFilter);
    notifyListeners();
  }

  void onChange(String? newMonth) {
    if (newMonth == null ||
        _selectedMonth.month() == newMonth ||
        _status == Status.loading) {
      return;
    }
    _selectedMonth = DateTimeString(newMonth);
    _entryFilter.changeMonth(_selectedMonth);
    if (_selectedMonth.month() == currentMonth.month()) {
      _entries = StateDoc.inUse?.entries.toList();
      if (_entries != null) {
        _status = Status.ready;
      } else {
        _status = Status.loading;
      }
      notifyListeners();
    } else {
      _status = Status.loading;
      _entries = null;
      notifyListeners();
      _getData();
    }
  }

  void _getData() async {
    try {
      final localPath = _reportFilePath(_compneyID, _selectedMonth.month());
      final file = io.File(localPath);
      if (!(await file.exists())) {
        final url = await _ref
            .child(_compneyID)
            .child("${_selectedMonth.month()}.json")
            .getDownloadURL();
        await _dio.download(
          url,
          localPath,
          onReceiveProgress: (res, tot) {
            _recive = res / tot;
            notifyListeners();
          },
        );
      }
      var rawData = RawObject(await file.readAsString());
      _entries = StateDoc.fromJson(
        rawData.toMap()["stateDoc"].toMap(),
        register: false,
      ).entries.toList();
      _status = Status.ready;
    } catch (err) {
      _status = Status.error;
    } finally {
      notifyListeners();
    }
  }
}

String _reportFilePath(String compneyID, String month) =>
    "${dir.path}/report/$compneyID/$month.json";
