import 'package:distributor/auth/auth.dart';

import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/layout/routes.dart';
import 'package:distributor/providers/location.dart';
import 'package:distributor/settings/create_compney.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectCompneyPage extends StatelessWidget {
  const SelectCompneyPage({Key? key, required this.fromGateWay})
      : super(key: key);
  final bool fromGateWay;
  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final configDocProvider = Provider.of<DocProvider<ConfigDoc>>(context);
    final distributors = configDocProvider.doc?.distributor.values;
    if (distributors == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Select a DISTRIBUTOR")),
        body: const Center(child: Text("No Data found !")),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a DISTRIBUTOR"),
        actions: [if (fromGateWay) SettingsWidgit.signOut<MyAuthUser>()],
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          final compney = distributors.elementAt(index);
          return ListTile(
            selected: compney.id == locationProvider.compneyID,
            trailing: compney.disable
                ? const Icon(Icons.warning, color: Colors.amberAccent)
                : null,
            title: Text(compney.name),
            subtitle: Text(compney.id),
            onTap: () {
              if (locationProvider.changeCompney(compney) && !fromGateWay) {
                Navigator.pop(context);
                Navigator.popAndPushNamed(
                    context, MainRoute.defaultRoute.route);
              }
            },
          );
        },
        separatorBuilder: (_, __) => const Divider(),
        itemCount: distributors.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CreateCompney(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
