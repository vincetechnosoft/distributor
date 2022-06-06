import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/utils/controller.dart';
import 'package:flutter/material.dart';

class CreateReturnBoxesEntry extends StatefulWidget {
  const CreateReturnBoxesEntry({Key? key, required this.buyer})
      : super(key: key);
  final BuyerInfo buyer;

  @override
  State<CreateReturnBoxesEntry> createState() => _CreateReturnBoxesEntryState();
}

class _CreateReturnBoxesEntryState extends State<CreateReturnBoxesEntry> {
  final boxes = TextEditingController();
  var loading = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Take Boxes from ${widget.buyer.name}"),
      content: ListView(shrinkWrap: true, children: [
        if (loading) const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            autofocus: !loading,
            readOnly: loading,
            controller: boxes,
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: "Boxes",
              suffix: GestureDetector(
                onTap: () {
                  boxes.text = "";
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
          child: const Text("Take Boxes"),
        )
      ],
    );
  }

  void makeEntry() async {
    setState(() {
      loading = true;
    });
    final res = await ReturnBoxesEntry(
      buyerNumber: widget.buyer.phoneNumber,
      boxes: controllerToInt(boxes),
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
