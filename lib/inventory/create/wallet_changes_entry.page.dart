import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/utils/controller.dart';

import 'package:flutter/material.dart';

class CreateWalletChangesEntry extends StatefulWidget {
  const CreateWalletChangesEntry(this.walletChangeType, {Key? key})
      : super(key: key);
  final WalletChangeType walletChangeType;

  @override
  State<CreateWalletChangesEntry> createState() =>
      _CreateWalletChangesEntryState();
}

class _CreateWalletChangesEntryState extends State<CreateWalletChangesEntry> {
  final amount = TextEditingController();
  final message = TextEditingController();
  var loading = false;
  String? error;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.walletChangeType.name),
      content: ListView(
        shrinkWrap: true,
        children: [
          if (loading) const LinearProgressIndicator(),
          TextField(
            autofocus: !loading,
            readOnly: loading,
            controller: amount,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: "Amount",
              suffix: GestureDetector(
                onTap: () {
                  amount.text = "";
                },
                child: const Icon(Icons.clear),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            readOnly: loading,
            controller: message,
            keyboardType: TextInputType.multiline,
            maxLength: 300,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: "Message",
              suffix: GestureDetector(
                onTap: () {
                  message.text = "";
                },
                child: const Icon(Icons.clear),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ErrorTile(error),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancle")),
        TextButton(
          onPressed: loading ? null : onPress,
          child: const Text("Apply"),
        ),
      ],
    );
  }

  void onPress() async {
    final amountVal = controllerToInt(amount);
    if (amountVal <= 0) {
      return setState(() {
        error = "* Amount must be +ve! (greater then zero)";
      });
    }
    setState(() {
      loading = true;
    });
    final res = await WalletChangesEntry(
      walletChangeType: widget.walletChangeType,
      amount: amountVal,
      message: message.text,
    ).addEntryToDoc(context);
    if (mounted) {
      if (res != null) {
        setState(() {
          loading = false;
          error = "* Retry?";
        });
        res.showAlertDialog(context: context);
      } else {
        Navigator.pop(context);
      }
    }
  }
}
