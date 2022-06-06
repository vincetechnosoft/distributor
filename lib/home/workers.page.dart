import 'package:distributor/auth/auth.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/home/widgets/create_worker.dart';
import 'package:distributor/home/widgets/editable_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompneyUserInfoPage extends StatelessWidget {
  const CompneyUserInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyAuthUser>(context);
    final compneyDoc = DocProvider.of<CompneyDoc>(context);
    final workers = compneyDoc.workers;
    final editPermitions = user.hasOwnerPermission;
    return Scaffold(
      appBar: AppBar(title: const Text("Worker Info")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          itemBuilder: (context, index) {
            final worker = workers.elementAt(index);
            return EditableTile(
              key: Key(worker.phoneNumber),
              lable: worker.phoneNumber,
              keybordType: TextInputType.name,
              onApplyChanges: (newVal) {
                return worker.makeChanges(newName: newVal);
              },
              onDeleteText: "${worker.name}\n${worker.phoneNumber}",
              onDelete: () {
                return worker.remove();
              },
              value: worker.name,
              disableEditing: !editPermitions,
              status: worker.userStatus.toNullBool(),
            );
          },
          separatorBuilder: (context, index) {
            return const Divider();
          },
          itemCount: workers.length,
        ),
      ),
      floatingActionButton: editPermitions
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const CreateWorker();
                  },
                );
              },
            )
          : null,
    );
  }
}
