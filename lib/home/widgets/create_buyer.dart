import 'package:bmi_b2b_package/bmi_b2b_package.dart';

import 'package:flutter/material.dart';

class CreateBuyer extends StatefulWidget {
  const CreateBuyer({Key? key}) : super(key: key);

  @override
  State<CreateBuyer> createState() => _CreateBuyerState();
}

class _CreateBuyerState extends State<CreateBuyer> {
  var loading = false;
  String? error;
  final phoneNumber = TextEditingController();
  final name = TextEditingController();
  final namesUsed = <String>{};
  final phoneUsed = <String>{};

  @override
  Widget build(BuildContext context) {
    final buyers = DocProvider.of<CompneyDoc>(context).buyers;
    if (loading) {
      return AlertDialog(
        title:
            loading ? const Text("Creating Buyer") : const Text("Loading..."),
        content: ListView(
          shrinkWrap: true,
          children: [
            const LinearProgressIndicator(),
            ListTile(title: const Text("Name"), subtitle: Text(name.text)),
            ListTile(
              title: const Text("Phone Number"),
              subtitle: Text(phoneNumber.text),
            ),
          ],
        ),
      );
    }
    for (var buyer in buyers) {
      namesUsed.add(buyer.name);
      phoneUsed.add(buyer.phoneNumber);
    }
    return AlertDialog(
      title: const Text("Add Buyer"),
      content: ListView(
        shrinkWrap: true,
        children: [
          GetContectNumber(onSelect: (info) {
            phoneNumber.text = info.phoneNumber;
            name.text = info.name ?? "";
          }),
          TextField(
            controller: name,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Name",
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            autofocus: true,
            controller: phoneNumber,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Phone Number",
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
          child: const Text("Cancle"),
        ),
        TextButton(
          onPressed: applyChanges,
          child: const Text("Create"),
        ),
      ],
    );
  }

  void applyChanges() async {
    var phoneStr = phoneNumber.text;
    if (phoneStr.startsWith("+91")) {
      phoneStr = phoneStr.substring(3);
    }
    if (phoneStr.startsWith("0")) phoneStr = phoneStr.substring(1);
    if (!phoneStr.startsWith("+91")) {
      phoneStr = "+91$phoneStr";
    }
    var nameStr = name.text;
    if (phoneStr.length < 13) {
      return setState(() {
        loading = false;
        error = "* PhoneNumber must have atlest 10 digit long";
      });
    }
    if (phoneStr.length > 14) {
      return setState(() {
        loading = false;
        error = "* PhoneNumber must have atMost 11 digit long";
      });
    }
    if (nameStr.isEmpty) {
      return setState(() {
        loading = false;
        error = "* Give a Name to remember by";
      });
    }
    if (phoneUsed.contains(phoneStr)) {
      return setState(() {
        loading = false;
        error = "* Phone Number is Already in Use";
      });
    }
    if (namesUsed.contains(nameStr)) {
      return setState(() {
        loading = false;
        error = "* Name is Already in Use";
      });
    }
    setState(() {
      loading = true;
      error = null;
    });
    final res =
        await BuyerInfo(name: nameStr, phoneNumber: phoneStr).makeChanges();
    if (mounted) {
      if (res == null) {
        Navigator.pop(context);
      } else {
        setState(() {
          loading = false;
          error = "* Something went wrong \n ${res.error}";
        });
      }
    }
  }
}
