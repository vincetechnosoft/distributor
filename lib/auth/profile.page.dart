import 'package:distributor/auth/auth.dart';
import 'package:distributor/layout/drawer.dart';
import 'package:distributor/providers/location.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/settings/create_compney.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key, required this.fromGateWay}) : super(key: key);
  final bool fromGateWay;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyAuthUser>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final configDoc = Provider.of<DocProvider<ConfigDoc>>(context).doc;
    final compneyID = locationProvider.compneyID;
    final compneyIDs = user.compneyIDs;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Page"),
        actions: [
          if (fromGateWay) SettingsWidgit.signOut<MyAuthUser>(),
        ],
      ),
      drawer: fromGateWay ? null : const MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            ListTile(
              title: const Text("Phone Number"),
              trailing: Text(user.phoneNumber),
            ),
            const Divider(),
            if (user.isDev) const HeaderTile(title: "You Are a Developer"),
            if (!user.isDev && compneyIDs.isNotEmpty) ...[
              const HeaderTile(title: "Compneys Avalable"),
              ...compneyIDs.map(
                (e) {
                  final info = configDoc?.distributor(e);
                  return ListTile(
                    enabled: user.hasCompney(e),
                    title: Text(info?.name ?? "Loading..."),
                    leading: const Icon(Icons.location_on_rounded),
                    selected: compneyID == e,
                    trailing: Text(user.hasRoleOf(e)),
                    onTap: info == null
                        ? null
                        : () => locationProvider.changeCompney(info),
                  );
                },
              ),
            ],
          ],
        ),
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
