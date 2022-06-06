import 'package:distributor/auth/auth.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/home/widgets/create_seller.dart';
import 'package:distributor/layout/drawer.dart';
import 'package:distributor/layout/routes.dart';
import 'package:distributor/sellers/create/buy_entry.page.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _Options { addSeller }

class SellerPage extends StatelessWidget {
  const SellerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyAuthUser>(context);
    final compneyDoc = DocProvider.of<CompneyDoc>(context);
    final stateDoc = DocProvider.of<StateDoc>(context);
    final sellers = compneyDoc.seller;
    final hasOwnerPermission = user.hasOwnerPermission;
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text("Sellers"),
        actions: [
          PopupMenuButton<_Options>(
            itemBuilder: (context) {
              return [
                PopupTile(
                  enabled: hasOwnerPermission,
                  child: "New Seller",
                  value: _Options.addSeller,
                  icon: const Icon(Icons.add),
                ),
              ];
            },
            onSelected: (option) {
              if (option == _Options.addSeller) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const CreateSeller();
                  },
                );
              }
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          final seller = sellers.elementAt(index);
          return ListTile(
            title: Text(seller.name),
            trailing: Text(stateDoc.getBuyInDuePayment(seller.id).toString()),
            subtitle: Text(
              "${stateDoc.getSellerEntries(seller.id).length} related Entries avalable",
            ),
            onTap: () {
              if (hasOwnerPermission) {
                SellerRoute.goTo(context, seller);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return BuyProduct(sellerID: seller.id);
                  }),
                );
              }
            },
          );
        },
        separatorBuilder: (context, index) {
          return const Divider();
        },
        itemCount: sellers.length,
      ),
    );
  }
}
