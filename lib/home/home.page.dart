import 'package:distributor/auth/auth.dart';
import 'package:distributor/home/widgets/create_user.dart';
import 'package:distributor/providers/location.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/home/widgets/editable_tile.dart';
import 'package:distributor/layout/drawer.dart';
import 'package:distributor/layout/routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

enum _Options {
  reset,
  delete,
  disable,
// enable
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyAuthUser>(context);
    final compneyDoc = DocProvider.of<CompneyDoc>(context);
    final compneyInfo = Provider.of<CompneyInfo>(context);
    final hasDevPermission = user.isDev;
    final hasOwnerPermission = user.hasOwnerPermission;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        actions: [
          if (hasOwnerPermission)
            PopupMenuButton<_Options>(
              itemBuilder: (context) {
                return hasDevPermission
                    ? [
                        PopupTile(
                          child: "Reset",
                          icon: Icon(
                            Icons.restore_page_rounded,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          value: _Options.reset,
                        ),
                        PopupTile(
                          enabled: !compneyDoc.action.disabled,
                          child: "Disable",
                          icon: const Icon(
                            Icons.warning,
                            color: Colors.amberAccent,
                          ),
                          value: _Options.disable,
                        ),
                        // PopupTile(
                        //   enabled: compneyDoc.action.disabled,
                        //   child: "Enable",
                        //   icon:
                        //       const Icon(Icons.check_box, color: Colors.green),
                        //   value: _Options.enable,
                        // ),
                        const PopupMenuDivider(),
                        PopupTile(
                          child: "Delete",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          icon: const Icon(
                            Icons.delete_forever_rounded,
                            color: Colors.redAccent,
                          ),
                          value: _Options.delete,
                        ),
                      ]
                    : [
                        PopupTile(
                          child: "Reset",
                          icon: Icon(
                            Icons.restore_page_rounded,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          value: _Options.reset,
                        ),
                      ];
              },
              onSelected: (option) async {
                switch (option) {
                  case _Options.reset:
                    if (await proceed(
                      context,
                      "Are you sure",
                      "Once reset, can't be undone!",
                    )) {
                      final res = await compneyDoc.action.resetData();
                      res?.showAlertDialog(context: context);
                    }
                    break;
                  case _Options.delete:
                    if (await proceed(
                      context,
                      "Are you sure",
                      "Once deleted, can't be undone!",
                    )) {
                      context.read<LocationProvider>().reset();
                      final res = await compneyInfo.deleteData();
                      res?.showAlertDialog(context: context);
                    }
                    break;
                  case _Options.disable:
                    if (await proceed(
                      context,
                      "Are you sure",
                      "This will disable compney completely",
                    )) {
                      final res = await compneyDoc.action.disableCompeny();
                      res?.showAlertDialog(context: context);
                    }
                    break;
                  // case _Options.enable:
                  //   if (await proceed(
                  //     context,
                  //     "Are you sure",
                  //     "This will enable the compney completely",
                  //   )) {
                  //     final res = await compneyDoc.action.enableCompeny();
                  //     res?.showAlertDialog(context: context);
                  //   }
                  //   break;
                }
              },
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
        child: ListView(
          children: [
            const HeaderTile(title: "Compney Info"),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 1000),
              child: compneyInfo.disable
                  ? const ErrorTile("* Compney is disabled currently")
                  : const SizedBox(),
            ),
            ListTile(
              title: const Text("Compney ID"),
              subtitle: Text(compneyInfo.id),
              trailing: IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: compneyInfo.id));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("URL copied"),
                  ));
                },
                icon: const Icon(Icons.copy),
              ),
            ),
            EditableTile(
              lable: "Compney Name",
              keybordType: TextInputType.text,
              onApplyChanges: (newVal) {
                return compneyInfo.makeChanges(newName: newVal);
              },
              value: compneyDoc.name,
              disableEditing: !user.hasOwnerPermission,
            ),
            const Divider(),
            const HeaderTile(title: "Connected Accounts"),
            ListTile(
              title: const Text("Owners"),
              subtitle: Text("${compneyDoc.owners.users.length} active users"),
              onTap: () {
                UserInfoRoute.goTo(context, UserType.owner);
              },
            ),
            ListTile(
              title: const Text("Worker"),
              subtitle: Text("${compneyDoc.workers.users.length} active users"),
              onTap: () {
                UserInfoRoute.goTo(context, UserType.worker);
              },
            ),
            const Divider(),
            const HeaderTile(title: "Products"),
            ListTile(
              title: const Text("Products"),
              onTap: () {
                SecondaryRoute.goTo(context, SecondaryPage.products);
              },
            ),
            const Divider(),
            const HeaderTile(title: "Other Accounts"),
            ListTile(
              title: const Text("Buyers"),
              subtitle: Text("${compneyDoc.buyers.users.length} active users"),
              onTap: () {
                UserInfoRoute.goTo(context, UserType.buyer);
              },
            ),
            ListTile(
              title: const Text("Sellers"),
              subtitle:
                  Text("${compneyDoc.seller.users.length} active accounts"),
              onTap: () {
                UserInfoRoute.goTo(context, UserType.seller);
              },
            ),
          ],
        ),
      ),
      drawer: const MyDrawer(),
    );
  }
}
