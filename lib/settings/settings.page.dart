import 'package:distributor/auth/auth.dart';

import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/layout/drawer.dart';
import 'package:distributor/layout/routes.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            const _SelectCompney(),
            const Divider(),
            SettingsWidgit.selectTheme(),
            const Divider(),
            SettingsWidgit.appInfo(),
            const Divider(),
            SettingsWidgit.signOut<MyAuthUser>(),
          ],
        ),
      ),
    );
  }
}

class _SelectCompney extends StatelessWidget {
  const _SelectCompney({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final compney = DocProvider.of<CompneyDoc>(context);
    final user = Provider.of<MyAuthUser>(context);
    final info = SecondaryRoute.get(SecondaryPage.selectCompney);
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: Text(info.name),
      leading: const Icon(Icons.location_on_rounded),
      trailing: compney.action.disabled
          ? const Icon(Icons.warning, color: Colors.amberAccent)
          : null,
      subtitle: Text(compney.name),
      enabled: user.isDev,
      onTap: () {
        info.navigate(context, argument: null);
      },
    );
  }
}
