import 'package:bmi_b2b_package/bmi_b2b_package.dart';

import 'package:flutter/material.dart';

extension on EntryType? {
  bool get containsBuyer {
    switch (this) {
      case EntryType.sell:
        return true;
      case EntryType.buy:
        return false;
      case EntryType.wasted:
        return false;
      case EntryType.buyInPayment:
        return false;
      case EntryType.sellOutPayment:
        return true;
      case EntryType.wallet:
        return false;
      case EntryType.returnBoxes:
        return true;
      case null:
        return true;
    }
  }

  bool get containsSeller {
    switch (this) {
      case EntryType.sell:
        return false;
      case EntryType.buy:
        return true;
      case EntryType.wasted:
        return false;
      case EntryType.buyInPayment:
        return true;
      case EntryType.sellOutPayment:
        return false;
      case EntryType.wallet:
        return false;
      case EntryType.returnBoxes:
        return false;
      case null:
        return true;
    }
  }

  String get displayName {
    switch (this) {
      case EntryType.sell:
        return "Sell";
      case EntryType.buy:
        return "Buy";
      case EntryType.wasted:
        return "Wastage";
      case EntryType.buyInPayment:
        return "Buy Payments";
      case EntryType.sellOutPayment:
        return "Sell Payments";
      case EntryType.wallet:
        return "Wallet Changes";
      case EntryType.returnBoxes:
        return "Boxes Returned";
      case null:
        return "All";
    }
  }
}

class EntryFilter {
  DateTimeRange? _dateTimeRange;
  EntryType? _entryType;
  String? _buyer;
  int? _seller;
  String? _creator;

  var _aDayOfMonth = DateTimeString.fromDateTime(DateTime.now());

  void changeMonth(DateTimeString month) {
    if (_aDayOfMonth.formateDate(name: false, withDate: false) !=
        month.formateDate(name: false, withDate: false)) return;
    _aDayOfMonth = month;
    _dateTimeRange = null;
  }

  EntryFilter();

  Iterable<Entry> call(Iterable<Entry> res) {
    final range = _dateTimeRange;
    if (range != null) {
      final start = DateTimeString.fromDateTime(range.start);
      final end = DateTimeString.fromDateTime(range.end);
      res = res.where((entry) {
        final date = entry.belongToDate;
        return start >= date && date >= end;
      });
    }

    final type = _entryType;
    if (type != null) {
      res = res.where((entry) {
        return entry.entryType == type;
      });
    }

    if (type.containsBuyer) {
      final buyer = _buyer;
      if (buyer != null) {
        res = res.where((entry) {
          if (entry is SoldEntry) {
            if (entry.buyerNumber == buyer) return true;
          } else if (entry is SellOutPaymentEntry) {
            if (entry.buyerNumber == buyer) return true;
          } else if (entry is ReturnBoxesEntry) {
            if (entry.buyerNumber == buyer) return true;
          }
          return false;
        });
      }
    }

    final seller = _seller;
    if (type.containsSeller) {
      if (seller != null) {
        res = res.where((entry) {
          if (entry is BoughtEntry) {
            if (entry.sellerID == seller) return true;
          } else if (entry is BuyInPaymentEntry) {
            if (entry.sellerID == seller) return true;
          }
          return false;
        });
      }
    }

    final creator = _creator;
    if (creator != null) {
      res = res.where((entry) {
        return entry.creator == creator;
      });
    }

    return res;
  }
}

extension on DateTimeRange {
  String toMonthString() {
    return "${DateTimeString.fromDateTime(start).formateDate(withYear: false)} -- ${DateTimeString.fromDateTime(end).formateDate(withYear: false)}";
  }
}

class _Widgit extends StatefulWidget {
  const _Widgit({Key? key, required this.filter}) : super(key: key);
  final EntryFilter filter;

  @override
  State<_Widgit> createState() => _WidgitState();
}

class _WidgitState extends State<_Widgit> {
  @override
  Widget build(BuildContext context) {
    final compneyDoc = DocProvider.of<CompneyDoc>(context);
    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          title: const Text(
            "Select Specific Date",
          ),
          trailing: TextButton(
            onPressed: () async {
              widget.filter._dateTimeRange = await showDateRangePicker(
                context: context,
                firstDate: widget.filter._aDayOfMonth.firstDayOfMonth,
                lastDate: widget.filter._aDayOfMonth.lastDayOfMonth,
                initialDateRange: widget.filter._dateTimeRange,
              );
              setState(() {});
            },
            child: Text(
              widget.filter._dateTimeRange?.toMonthString() ?? "--",
            ),
          ),
        ),
        ListTile(
          title: const Text("Type"),
          trailing: DropdownButton<EntryType?>(
            value: widget.filter._entryType,
            items: [
              const DropdownMenuItem(child: Text("All")),
              ...EntryType.values.map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.displayName),
                ),
              )
            ],
            onChanged: (res) {
              widget.filter._entryType = res;
              setState(() {});
            },
          ),
        ),
        ListTile(
          title: const Text("Creator"),
          trailing: DropdownButton<String?>(
            value: widget.filter._creator,
            items: [
              const DropdownMenuItem(child: Text("All")),
              DropdownMenuItem(
                value: compneyDoc.owner.phoneNumber,
                enabled: compneyDoc.owner.userStatus != UserStatus.error,
                child: Text(compneyDoc.owner.name),
              ),
              ...compneyDoc.workers.map(
                (e) => DropdownMenuItem(
                  value: e.phoneNumber,
                  child: Text(e.name),
                ),
              )
            ],
            onChanged: (res) {
              widget.filter._creator = res;
              setState(() {});
            },
          ),
        ),
        ListTile(
          title: const Text("Buyer"),
          trailing: DropdownButton<String?>(
            value: widget.filter._buyer,
            items: [
              const DropdownMenuItem(child: Text("All")),
              ...compneyDoc.buyers.map(
                (e) => DropdownMenuItem(
                  value: e.phoneNumber,
                  child: Text(e.name),
                ),
              )
            ],
            onChanged: widget.filter._entryType.containsBuyer
                ? (res) {
                    widget.filter._buyer = res;
                    setState(() {});
                  }
                : null,
          ),
        ),
        ListTile(
          title: const Text("Seller"),
          trailing: DropdownButton<int?>(
            value: widget.filter._seller,
            items: [
              const DropdownMenuItem(child: Text("All")),
              ...compneyDoc.seller.map(
                (e) => DropdownMenuItem(
                  value: e.id,
                  child: Text(e.name),
                ),
              )
            ],
            onChanged: widget.filter._entryType.containsSeller
                ? (res) {
                    widget.filter._seller = res;
                    setState(() {});
                  }
                : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Done"),
              )
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> showEntryFilter(BuildContext context, EntryFilter filter) {
  return showModalBottomSheet(
    context: context,
    builder: (context) => _Widgit(filter: filter),
  );
}
