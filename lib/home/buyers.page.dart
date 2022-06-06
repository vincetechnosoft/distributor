import 'package:distributor/auth/auth.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/home/widgets/create_buyer.dart';
import 'package:distributor/home/widgets/editable_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuyerInfoPage extends StatelessWidget {
  const BuyerInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyAuthUser>(context);
    final compneyDoc = DocProvider.of<CompneyDoc>(context);
    final buyers = compneyDoc.buyers;
    final editPermitions = user.hasOwnerPermission;
    return Scaffold(
      appBar: AppBar(title: const Text("Compney Buyer Info")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          itemBuilder: (context, index) {
            final buyer = buyers.elementAt(index);
            return EditableTile(
              key: Key(buyer.phoneNumber),
              lable: buyer.phoneNumber,
              keybordType: TextInputType.name,
              onApplyChanges: (newVal) {
                return buyer.makeChanges(newName: newVal);
              },
              onDeleteText: "${buyer.name}\n${buyer.phoneNumber}",
              onDelete: () {
                return buyer.remove();
              },
              value: buyer.name,
              disableEditing: !editPermitions,
            );
          },
          separatorBuilder: (context, index) {
            return const Divider();
          },
          itemCount: buyers.length,
        ),
      ),
      floatingActionButton: editPermitions
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const CreateBuyer();
                  },
                );
              },
            )
          : null,
    );
  }
}
