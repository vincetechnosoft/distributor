import 'package:bmi_b2b_package/bmi_b2b_package.dart';

import 'package:flutter/material.dart';

class CreateSeller extends StatefulWidget {
  const CreateSeller({Key? key}) : super(key: key);

  @override
  State<CreateSeller> createState() => _CreateSellerState();
}

class _CreateSellerState extends State<CreateSeller> {
  var loading = false;
  String? error;
  final name = TextEditingController();
  final namesUsed = <String>{};
  @override
  Widget build(BuildContext context) {
    final sellers = DocProvider.of<CompneyDoc>(context).seller;
    if (loading) {
      return AlertDialog(
        title:
            loading ? const Text("Creating seller") : const Text("Loading..."),
        content: ListView(
          shrinkWrap: true,
          children: [
            const LinearProgressIndicator(),
            ListTile(title: const Text("Name"), subtitle: Text(name.text)),
          ],
        ),
      );
    }
    for (var seller in sellers) {
      namesUsed.add(seller.name);
    }
    return AlertDialog(
      title: const Text("Add Seller"),
      content: ListView(
        shrinkWrap: true,
        children: [
          TextField(
            autofocus: true,
            controller: name,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Name",
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
          onPressed: () async {
            var nameStr = name.text.trim();
            if (nameStr.isEmpty) {
              return setState(() {
                loading = false;
                error = "* Give a Name to remember by";
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
            final res = await SellerInfo(name: nameStr).makeChanges();
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
          },
          child: const Text("Create"),
        ),
      ],
    );
  }
}
