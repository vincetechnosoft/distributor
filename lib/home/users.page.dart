import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/home/widgets/create_user.dart';
import 'package:distributor/home/widgets/editable_tile.dart';
import 'package:flutter/material.dart';

class CompneyUserInfoPage extends StatelessWidget {
  const CompneyUserInfoPage({Key? key, required this.userType})
      : super(key: key);
  final UserType userType;
  @override
  Widget build(BuildContext context) {
    final compneyDoc = DocProvider.of<CompneyDoc>(context);
    final Iterable<UserInfo> users;
    switch (userType) {
      case UserType.owner:
        users = compneyDoc.owners.users;
        break;
      case UserType.worker:
        users = compneyDoc.workers.users;
        break;
      case UserType.buyer:
        users = compneyDoc.buyers.users;
        break;
      case UserType.seller:
        users = compneyDoc.seller.users;
        break;
    }
    return Scaffold(
      appBar: AppBar(title: Text("${userType.name} Info")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          itemBuilder: (context, index) {
            final user = users.elementAt(index);
            return EditableTile(
              key: Key(user.phoneNumber),
              lable: user.phoneNumber,
              keybordType: TextInputType.name,
              onApplyChanges: (newVal) {
                return user.makeChanges(newName: newVal);
              },
              onDeleteText: "${user.name}\n${user.phoneNumber}",
              onDelete: () {
                return user.remove();
              },
              value: user.name,
              disableEditing: false,
              status: user is WorkerInfo
                  ? user.userStatus.toNullBool()
                  : user is OwnerInfo
                      ? user.userStatus.toNullBool()
                      : null,
            );
          },
          separatorBuilder: (context, index) {
            return const Divider();
          },
          itemCount: users.length,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return CreateUser(userType: userType);
            },
          );
        },
      ),
    );
  }
}
