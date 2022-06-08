import 'package:distributor/utils/utils.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';

import 'package:flutter/material.dart';

class _ItemSold extends InventoryProductController {
  final IntMoney rate;
  final IntMoney discount;
  _ItemSold(Product product, BuyerInfo buyer)
      : rate = product.rate,
        discount = product.customerDiscount[buyer.phoneNumber] ??
            product.defaultDiscount,
        super(product);
}

class SellProduct extends StatefulWidget {
  const SellProduct({Key? key, required this.buyerNumber}) : super(key: key);
  final String buyerNumber;

  @override
  State<SellProduct> createState() => _SellProductState();
}

class _SellProductState extends State<SellProduct> {
  var loading = false;
  final Map<int, _ItemSold> itemsSold = {};

  @override
  Widget build(BuildContext context) {
    final compneyDoc = DocProvider.of<CompneyDoc>(context);
    final productDoc = DocProvider.of<ProductDoc>(context);
    final items = productDoc.items;
    final buyer = compneyDoc.getBuyer(widget.buyerNumber);
    return Scaffold(
      appBar: AppBar(title: Text("Selling To ${buyer.name}")),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListView.builder(
          itemCount: loading ? items.length + 1 : items.length,
          itemBuilder: (context, index) {
            if (loading && index-- == 0) return const LinearProgressIndicator();
            final item = items.elementAt(index);
            final controller = itemsSold[item.id] ??= _ItemSold(item, buyer);
            return ListTile(title: InputQuntity(controller, loading: loading));
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

    final res = await SoldEntry(
      buyerNumber: widget.buyerNumber,
      itemSold: itemsSold.entries.map(
        (e) => ItemSold(
          id: e.key,
          quntity: e.value.intQ,
          rate: e.value.rate,
          discountApplyed: e.value.discount,
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
      }
      Navigator.pop(context);
    }
  }
}
