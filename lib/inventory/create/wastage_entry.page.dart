import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/auth/auth.dart';
import 'package:distributor/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _ItemChanges extends InventoryProductController {
  _ItemChanges(Product product) : super(product);
}

class CreateWastageEntryPage extends StatefulWidget {
  const CreateWastageEntryPage({Key? key}) : super(key: key);

  @override
  State<CreateWastageEntryPage> createState() => _CreateWastageEntryPageState();
}

class _CreateWastageEntryPageState extends State<CreateWastageEntryPage> {
  var loading = false;
  var wasted = <int, _ItemChanges>{};

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyAuthUser>(context);
    final productDoc = DocProvider.of<ProductDoc>(context);
    final stateDoc = DocProvider.of<StateDoc>(context);
    final getQuntityOf = stateDoc.getQuntityOf;
    final items = productDoc.items;
    if (!user.hasOwnerPermission) {
      return const ErrorPage(
        fromGateWay: false,
        title: "Create Wastage Entry",
        errorObj: "No Permissions Found",
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Create Wastage Entry")),
      body: ListView.builder(
        itemCount: loading ? items.length + 1 : items.length,
        itemBuilder: (context, index) {
          if (loading && index-- == 0) return const LinearProgressIndicator();
          final item = items.elementAt(index);
          final controller = wasted[item.id] ??= _ItemChanges(item);
          final inv = getQuntityOf(item.id.toString());
          return ListTile(
            title: InputQuntity(controller, loading: loading),
            subtitle: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Box:  ${inv.quntity}"),
                  Text(item.pckInBox == null
                      ? ""
                      : "Pack:  ${inv.pack.toString()}"),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: loading
            ? null
            : () async {
                setState(() {
                  loading = true;
                });
                final res = await WastageEntry(
                  wastedItems: wasted.entries.map(
                    (e) => ItemChanges(
                      id: e.key,
                      quntity: e.value.intQ,
                      pack: e.value.intP,
                    ),
                  ),
                ).addEntryToDoc(context);
                if (mounted) {
                  if (res != null) {
                    res.showAlertDialog(context: context);
                    setState(() {
                      loading = false;
                    });
                  } else {
                    Navigator.pop(context);
                  }
                }
              },
        child: const Icon(Icons.check),
      ),
    );
  }
}
