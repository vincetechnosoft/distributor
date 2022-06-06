import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/utils/controller.dart';
import 'package:flutter/material.dart';

class CreateSellerPaymentEntry extends StatefulWidget {
  const CreateSellerPaymentEntry({
    Key? key,
    required this.seller,
  }) : super(key: key);
  final SellerInfo seller;

  @override
  State<CreateSellerPaymentEntry> createState() =>
      _CreateSellerPaymentEntryState();
}

class _CreateSellerPaymentEntryState extends State<CreateSellerPaymentEntry> {
  final amount = TextEditingController();
  var loading = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Pay To ${widget.seller.name}"),
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
          child: const Text("Pay"),
        )
      ],
    );
  }

  void makeEntry() async {
    setState(() {
      loading = true;
    });
    final res = await BuyInPaymentEntry(
      sellerID: widget.seller.id,
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
