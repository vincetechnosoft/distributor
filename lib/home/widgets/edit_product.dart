import 'package:distributor/auth/auth.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/utils/utils.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({Key? key, required this.productID}) : super(key: key);

  final int? productID;

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  String? error;
  int? createdID;
  bool created = false;
  var editMode = false;
  var deleting = false;
  var loading = false;
  final pckPerBox = TextEditingController();
  final name = TextEditingController();
  final rate = TextEditingController();
  final rankOrderValue = TextEditingController();
  final defaultDiscount = TextEditingController();
  final customerDiscount = <String, TextEditingController>{};
  final sellerRate = <String, TextEditingController>{};
  final defaultBoughtRate = TextEditingController();
  final customerName = <String, String>{};
  final sellerName = <String, String>{};

  int? get productID => widget.productID ?? createdID;

  Text get title => productID == null
      ? const Text("Create Item")
      : editMode
          ? const Text("Edit Item")
          : const Text("Item Page");

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyAuthUser>(context);
    final hasPermission = user.hasOwnerPermission;
    final productDoc = DocProvider.of<ProductDoc>(context);
    final compneyDoc = DocProvider.of<CompneyDoc>(context);
    final buyers = compneyDoc.buyers;
    final sellers = compneyDoc.seller;
    for (var buyer in buyers.users) {
      customerName[buyer.phoneNumber] = buyer.name;
    }
    for (var seller in sellers.users) {
      sellerName[seller.phoneNumber] = seller.name;
    }
    final id = productID;
    final product =
        id == null ? null : productDoc.getItem(productID.toString());
    if (!hasPermission && widget.productID == null) {
      return const ErrorPage(
        fromGateWay: false,
        title: "Product Creation",
        errorObj: "You don't have authorization to do create products",
      );
    }
    if (loading || (created && product == null)) return loadingUI();
    if (product == null || editMode) {
      return editItemUI(buyers, sellers, productDoc, product);
    }
    return noramlUI(hasPermission, product);
  }

  Scaffold noramlUI(bool hasPermission, Product product) {
    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: hasPermission && !deleting
            ? [
                IconButton(
                  onPressed: () {
                    setState(() {
                      editMode = true;
                      name.text = product.name;
                      rate.text = _intToString(product.rate.money);
                      rankOrderValue.text = product.rankOrderValue.toString();
                      defaultBoughtRate.text =
                          _intToString(product.defaultBoughtRate.money);
                      defaultDiscount.text =
                          _intToString(product.defaultDiscount.money);
                      sellerRate.addAll(
                        product.sellerRate.map(
                          (key, value) => MapEntry(
                            key,
                            TextEditingController(
                              text: _intToString(value.money),
                            ),
                          ),
                        ),
                      );
                      customerDiscount.addAll(
                        product.customerDiscount.map(
                          (key, value) => MapEntry(
                            key,
                            TextEditingController(
                              text: _intToString(value.money),
                            ),
                          ),
                        ),
                      );
                    });
                  },
                  icon: const Icon(Icons.edit),
                ),
              ]
            : null,
      ),
      body: ListView(
        children: [
          if (deleting) const LinearProgressIndicator(color: Colors.red),
          const HeaderTile(title: "Info"),
          displayInfo("Name", product.name),
          displayInfo("Ranking Order Val", product.rankOrderValue.toString()),
          displayInfo(
            "Pack Per Box",
            product.pckInBox?.toString() ?? "- -",
          ),
          const Divider(),
          const HeaderTile(title: "Sellers Info"),
          displayInfo(
            "Default Rate",
            product.defaultBoughtRate.toString(),
          ),
          ...product.sellerRate.entries.map(
            (e) {
              final nameOfSeller = sellerName[e.key];
              return displayInfo(
                nameOfSeller ?? "ID = ${e.key}",
                e.value.toString(),
                pointer: true,
              );
            },
          ).toList(),
          const Divider(),
          const HeaderTile(title: "Buyer Info"),
          displayInfo("Rate", product.rate.toString()),
          displayInfo("Default Discount", product.defaultDiscount.toString()),
          ...product.customerDiscount.entries.map(
            (e) {
              final nameOfCustomer = customerName[e.key];
              return displayInfo(
                nameOfCustomer ?? e.key,
                e.value.toString(),
                pointer: true,
              );
            },
          ).toList()
        ],
      ),
      floatingActionButton: !hasPermission || deleting
          ? null
          : FloatingActionButton(
              onPressed: () async {
                if (!await proceed(
                  context,
                  "Are You Sure To Remove",
                  "Warning, once deleted can't be undone!",
                )) return;
                setState(() {
                  deleting = true;
                });
                final res = await product.remove();
                if (mounted) {
                  res?.showAlertDialog(context: context);
                  Navigator.pop(context);
                }
              },
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.delete),
            ),
    );
  }

  Scaffold loadingUI() {
    return Scaffold(
      appBar: AppBar(title: title),
      body: ListView(
        children: [
          const LinearProgressIndicator(),
          const HeaderTile(title: "Info"),
          displayInfo("Name", name.text),
          displayInfo("Ranking Order Val", rankOrderValue.text),
          if (productID == null) displayInfo("Pack Per Box", pckPerBox.text),
          const Divider(),
          const HeaderTile(title: "Sellers Info"),
          displayInfo("Default Rate", defaultBoughtRate.text),
          ...sellerRate.entries
              .map(
                (e) => displayInfo(
                  sellerName[e.key] ?? "ID = ${e.key}",
                  e.value.text,
                  pointer: true,
                ),
              )
              .toList(),
          const Divider(),
          const HeaderTile(title: "Customer Discount"),
          displayInfo("Rate", rate.text),
          displayInfo("Default Discount", defaultDiscount.text),
          ...customerDiscount.entries
              .map(
                (e) => displayInfo(
                  customerName[e.key] ?? e.key,
                  e.value.text,
                  pointer: true,
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Scaffold editItemUI(UsersInfo<BuyerInfo> buyers,
      UsersInfo<SellerInfo> sellers, ProductDoc productDoc, Product? item) {
    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: [
          IconButton(
            onPressed: () => item == null
                ? createItem(productDoc)
                : editItem(productDoc.items, item),
            icon: const Icon(Icons.check),
          )
        ],
        leading: editMode
            ? IconButton(
                onPressed: () {
                  setState(() {
                    editMode = false;
                  });
                },
                icon: const Icon(Icons.clear),
              )
            : null,
      ),
      body: ListView(
        children: [
          if (error != null) ...[
            const HeaderTile(title: "Error Occured"),
            ErrorTile(error),
            const Divider(),
          ],
          const HeaderTile(title: "Info"),
          textField("Name", name, item?.name),
          textField(
            "Ranking Order Val",
            rankOrderValue,
            item?.rankOrderValue.toString(),
            isNum: true,
          ),
          if (item == null)
            textField(
              "Pack Per Box",
              pckPerBox,
              null,
              isNum: true,
            ),
          const Divider(),
          HeaderTile(
            title: "Seller Info",
            trailing: sellers.users.isEmpty
                ? null
                : PopupMenuButton<SellerInfo>(
                    child: const Icon(Icons.add),
                    itemBuilder: (context) {
                      return sellers.users.map((e) {
                        return PopupMenuItem(
                          enabled: !sellerRate.containsKey(e.phoneNumber),
                          value: e,
                          child: Text(e.name),
                        );
                      }).toList();
                    },
                    onSelected: (seller) {
                      setState(() {
                        sellerRate[seller.phoneNumber] =
                            TextEditingController();
                      });
                    },
                  ),
          ),
          textField(
            "Default Rate (in Rs.)",
            defaultBoughtRate,
            _intToString(item?.defaultBoughtRate.money),
            isNum: true,
          ),
          ...sellerRate.entries.map((e) {
            return textField(
              sellerName[e.key] ?? "ID = ${e.key}",
              e.value,
              _intToString(item?.customerDiscount[e.key]?.money),
              isNum: true,
              pointer: true,
              onDelete: () {
                setState(() {
                  sellerRate.remove(e.key);
                });
              },
            );
          }),
          HeaderTile(
            title: "Buyer Info",
            trailing: buyers.users.isEmpty
                ? null
                : PopupMenuButton<BuyerInfo>(
                    child: const Icon(Icons.add),
                    itemBuilder: (context) {
                      return buyers.users.map((e) {
                        return PopupMenuItem(
                          enabled: !customerDiscount.containsKey(e.phoneNumber),
                          value: e,
                          child: Text(e.name),
                        );
                      }).toList();
                    },
                    onSelected: (buyer) {
                      setState(() {
                        customerDiscount[buyer.phoneNumber] =
                            TextEditingController();
                      });
                    },
                  ),
          ),
          const Divider(),
          textField(
            "Rate (in Rs.)",
            rate,
            _intToString(item?.rate.money),
            isNum: true,
          ),
          textField(
            "Default Discount (in Rs.)",
            defaultDiscount,
            _intToString(item?.defaultDiscount.money),
            isNum: true,
          ),
          ...customerDiscount.entries.map((e) {
            return textField(
              customerName[e.key] ?? e.key,
              e.value,
              _intToString(item?.customerDiscount[e.key]?.money),
              isNum: true,
              pointer: true,
              onDelete: () {
                setState(() {
                  customerDiscount.remove(e.key);
                });
              },
            );
          })
        ],
      ),
    );
  }

  void editItem(Iterable<Product> items, Product product) async {
    final finalName = name.text.trim();
    if (finalName.isEmpty) {
      return setState(() {
        loading = false;
        error = "* No Name Found, give a name";
      });
    }
    final lowerCaseName = finalName.toLowerCase();
    for (var item in items) {
      if (item.name.toLowerCase().trim() == lowerCaseName &&
          item.id != product.id) {
        return setState(() {
          loading = false;
          error = "* Name Already In Use, give unique name";
        });
      }
    }
    setState(() {
      loading = true;
      error = null;
    });
    final res = await product.makeChanges(
      newCustomerDiscount: customerDiscount
          .map((key, value) => MapEntry(key, controllerToInt(value))),
      newDefaultDiscount: controllerToInt(defaultDiscount),
      newName: finalName,
      newRate: controllerToInt(rate),
      newRankOrderValue: toInt(rankOrderValue.text),
      newDefaultBoughtRate: controllerToInt(defaultBoughtRate),
      newSellerRate:
          sellerRate.map((key, value) => MapEntry(key, controllerToInt(value))),
    );
    if (mounted) {
      res?.showAlertDialog(context: context);
      setState(() {
        editMode = false;
        error = null;
        loading = false;
      });
      if (res != null) Navigator.pop(context);
    }
  }

  void createItem(ProductDoc productDoc) async {
    final finalName = name.text.trim();
    if (finalName.isEmpty) {
      return setState(() {
        loading = false;
        error = "* No Name Found, give a name";
      });
    }
    final lowerCaseName = finalName.toLowerCase();
    for (var item in productDoc.items) {
      if (item.name.toLowerCase().trim() == lowerCaseName) {
        return setState(() {
          loading = false;
          error = "* Name Already In Use, give unique name";
        });
      }
    }
    setState(() {
      loading = true;
      error = null;
    });
    final pckInBox = controllerToInt(pckPerBox);
    final product = Product(
      rankOrderValue: toInt(rankOrderValue.text),
      customerDiscount: customerDiscount
          .map((key, value) => MapEntry(key, controllerToInt(value))),
      defaultDiscount: controllerToInt(defaultDiscount),
      name: finalName,
      rate: controllerToInt(rate),
      defaultBoughtRate: controllerToInt(defaultBoughtRate),
      pckInBox: pckInBox <= 0 ? null : pckInBox,
      sellerRate:
          sellerRate.map((key, value) => MapEntry(key, controllerToInt(value))),
    );
    final res = await product.makeChanges();
    if (mounted) {
      res?.showAlertDialog(context: context);
      setState(() {
        error = null;
        loading = false;
        if (res == null) {
          created = true;
          createdID = product.id;
        }
      });
    }
  }

  ListTile displayInfo(
    String lable,
    String value, {
    bool pointer = false,
  }) {
    return ListTile(
      leading: pointer
          ? const Icon(Icons.keyboard_double_arrow_right_rounded)
          : null,
      title: Text(lable),
      trailing: Text(value),
    );
  }

  ListTile textField(
    String lable,
    TextEditingController controller,
    String? undoChanges, {
    void Function()? onDelete,
    bool isNum = false,
    bool pointer = false,
  }) {
    return ListTile(
      leading: GestureDetector(
        child: const Icon(Icons.undo),
        onTap: () {
          controller.text = undoChanges ?? "";
        },
      ),
      trailing: onDelete != null
          ? GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.delete),
            )
          : null,
      key: Key(lable),
      title: TextField(
        key: Key(lable),
        controller: controller,
        keyboardType:
            isNum ? const TextInputType.numberWithOptions(decimal: true) : null,
        decoration: InputDecoration(
          border: pointer ? null : const OutlineInputBorder(),
          labelText: lable,
        ),
      ),
    );
  }
}

String _intToString(int? val) {
  if (val == null) return "";
  return (val / 1000).toString();
}
