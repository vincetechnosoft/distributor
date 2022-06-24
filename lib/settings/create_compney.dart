import 'package:bmi_b2b_package/bmi_b2b_package.dart';

import 'package:flutter/material.dart';

class CreateCompney extends StatefulWidget {
  const CreateCompney({Key? key}) : super(key: key);

  @override
  State<CreateCompney> createState() => _CreateCompneyState();
}

class _CreateCompneyState extends State<CreateCompney> {
  final name = TextEditingController();
  var loading = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Compney"),
      content: ListView(shrinkWrap: true, children: [
        if (loading) const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            autofocus: !loading,
            readOnly: loading,
            controller: name,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: "Name",
              suffix: GestureDetector(
                onTap: () {
                  name.text = "";
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
          onPressed: loading ? null : makeCompney,
          child: const Text("Create"),
        )
      ],
    );
  }

  void makeCompney() async {
    setState(() {
      loading = true;
    });
    final newCompney = CompneyInfo(name.text);
    final res = await newCompney.makeChanges();
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
