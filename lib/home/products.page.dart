import 'package:distributor/auth/auth.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/home/widgets/edit_product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductInfoPage extends StatelessWidget {
  const ProductInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyAuthUser>(context);
    final productDoc = DocProvider.of<ProductDoc>(context);
    final items = productDoc.items;
    final hasPermission = user.hasOwnerPermission;
    return Scaffold(
      appBar: AppBar(title: const Text("Product's Info")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) {
              return const Divider();
            },
            itemBuilder: (context, index) {
              final product = items.elementAt(index);
              return ListTile(
                title: Text("(${product.rankOrderValue})  ${product.name}"),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Bought Rate"),
                          Text(product.defaultBoughtRate.toString()),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Sell Rate"),
                          Text(product.rate.toString()),
                        ],
                      ),
                    ],
                  ),
                ),
                onTap: hasPermission
                    ? () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ItemPage(productID: product.id);
                        }));
                      }
                    : null,
              );
            }),
      ),
      floatingActionButton: hasPermission
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const ItemPage(productID: null);
                }));
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
