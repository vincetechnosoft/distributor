import 'package:distributor/utils/controller.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:flutter/material.dart';

class CreateBuyerPaymentEntry extends StatefulWidget {
  const CreateBuyerPaymentEntry({Key? key, required this.buyer})
      : super(key: key);
  final BuyerInfo buyer;

  @override
  State<CreateBuyerPaymentEntry> createState() =>
      _CreateBuyerPaymentEntryState();
}

class _CreateBuyerPaymentEntryState extends State<CreateBuyerPaymentEntry> {
  final amount = TextEditingController();
  var loading = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Pay To ${widget.buyer.name}"),
      content: ListView(shrinkWrap: true, children: [
        if (loading) const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            autofocus: !loading,
            readOnly: loading,
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: "Payment (in Rs)",
              suffix: GestureDetector(
                onTap: () {
                  amount.text = "";
                },
                child: const Icon(Icons.clear),
              ),
            ),
          ),
        ),
      ]),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancle"),
        ),
        TextButton(
          onPressed: loading ? null : makeEntry,
          child: const Text("Take Payment"),
        )
      ],
    );
  }

  void makeEntry() async {
    setState(() {
      loading = true;
    });
    final res = await SellOutPaymentEntry(
      buyerNumber: widget.buyer.phoneNumber,
      amount: controllerToInt(amount),
    ).addEntryToDoc(context);
    if (mounted) {
      if (res != null) {
        setState(() {
          loading = false;
        });
        res.showAlertDialog(context: context);
      } else {
        Navigator.pop(context);
      }
    }
  }
}
