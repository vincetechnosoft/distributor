import 'package:distributor/auth/auth.dart';
import 'package:distributor/buyers/create/sell_entry.page.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/home/widgets/create_user.dart';
import 'package:distributor/layout/drawer.dart';
import 'package:distributor/layout/routes.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _Options { addBuyer }

class BuyerPage extends StatelessWidget {
  const BuyerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyAuthUser>(context);
    final compneyDoc = DocProvider.of<CompneyDoc>(context);
    final stateDoc = DocProvider.of<StateDoc>(context);
    final buyers = compneyDoc.buyers;
    final hasOwnerPermission = user.hasOwnerPermission;
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text("Buyers"),
        actions: [
          PopupMenuButton<_Options>(
            itemBuilder: (context) {
              return [
                PopupTile(
                  child: "New Buyer",
                  value: _Options.addBuyer,
                  icon: const Icon(Icons.add),
                  enabled: hasOwnerPermission,
                ),
              ];
            },
            onSelected: (option) {
              if (option == _Options.addBuyer) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const CreateUser(userType: UserType.buyer);
                  },
                );
              }
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          final buyer = buyers.elementAt(index);
          return ListTile(
            title: Text(buyer.name),
            trailing: Text(
              stateDoc.getSellOutDuePayment(buyer.phoneNumber).toString(),
            ),
            subtitle: Text(
              "${stateDoc.getSellOutDueBoxes(buyer.phoneNumber)} Due Boxes",
            ),
            onTap: () {
              if (hasOwnerPermission) {
                BuyerRoute.goTo(context, buyer);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return SellProduct(buyerNumber: buyer.phoneNumber);
                  }),
                );
              }
            },
          );
        },
        separatorBuilder: (context, index) {
          return const Divider();
        },
        itemCount: buyers.length,
      ),
    );
  }
}
