import 'package:distributor/auth/auth.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/home/widgets/create_seller.dart';
import 'package:flutter/material.dart';
import 'package:distributor/home/widgets/editable_tile.dart';
import 'package:provider/provider.dart';

class SellerInfoPage extends StatelessWidget {
  const SellerInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyAuthUser>(context);
    final compneyDoc = DocProvider.of<CompneyDoc>(context);
    final sellers = compneyDoc.seller;
    final editPermitions = user.hasOwnerPermission;
    return Scaffold(
      appBar: AppBar(title: const Text("Seller Info")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          itemBuilder: (context, index) {
            final seller = sellers.elementAt(index);
            return EditableTile(
              key: Key(seller.id.toString()),
              lable: "ID: ${seller.id}",
              keybordType: TextInputType.name,
              onApplyChanges: (newVal) {
                return seller.makeChanges(newName: newVal);
              },
              onDeleteText: "ID: ${seller.id}\n${seller.name}",
              onDelete: () {
                return seller.remove();
              },
              value: seller.name,
              disableEditing: !editPermitions,
            );
          },
          separatorBuilder: (context, index) {
            return const Divider();
          },
          itemCount: sellers.length,
        ),
      ),
      floatingActionButton: editPermitions
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const CreateSeller();
                  },
                );
              },
            )
          : null,
    );
  }
}
