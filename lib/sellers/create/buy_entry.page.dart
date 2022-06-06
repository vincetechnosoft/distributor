import 'package:distributor/auth/auth.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/utils/controller.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _ItemBought extends InventoryProductController {
  final IntMoney rate;
  _ItemBought(Product product, SellerInfo seller)
      : rate = product.sellerRate[seller.id] ?? product.defaultBoughtRate,
        super(product);
}

class BuyProduct extends StatefulWidget {
  const BuyProduct({Key? key, required this.sellerID}) : super(key: key);
  final int sellerID;

  @override
  State<BuyProduct> createState() => _BuyProductState();
}

class _BuyProductState extends State<BuyProduct> {
  var loading = false;
  final Map<int, _ItemBought> itemsBought = {};

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyAuthUser>(context);
    final compneyDoc = DocProvider.of<CompneyDoc>(context);
    final productDoc = DocProvider.of<ProductDoc>(context);
    final items = productDoc.items;
    final seller = compneyDoc.getSeller(widget.sellerID);
    final hasOwnerPermission = user.hasOwnerPermission;
    return Scaffold(
      appBar: AppBar(title: Text("Buying from ${seller.name}")),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListView.builder(
          itemCount: loading ? items.length + 1 : items.length,
          itemBuilder: (context, index) {
            if (loading && index-- == 0) return const LinearProgressIndicator();
            final item = items.elementAt(index);
            final controller =
                itemsBought[item.id] ??= _ItemBought(item, seller);
            return ListTile(
              title: InputQuntity(controller, loading: loading),
              subtitle: hasOwnerPermission
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Rate"),
                              Text(controller.rate.toString()),
                            ],
                          ),
                        ],
                      ),
                    )
                  : null,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: loading ? null : makeEntry,
        child: const Icon(Icons.check),
      ),
    );
  }

  void makeEntry() async {
    setState(() {
      loading = true;
    });
    final bE = BoughtEntry(
      itemBought: itemsBought.entries.map(
        (e) => ItemBought(
          id: e.key,
          quntity: e.value.intQ,
          pack: e.value.intP,
          rate: e.value.rate,
        ),
      ),
      sellerID: widget.sellerID,
    );
    final res = await bE.addEntryToDoc(context);
    if (mounted) {
      if (res != null) {
        res.showAlertDialog(context: context);
        setState(() {
          loading = false;
        });
      }
      Navigator.pop(context);
    }
  }
}
