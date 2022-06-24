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
            const _CompneyLife(),
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

class _CompneyLife extends StatelessWidget {
  const _CompneyLife({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final compneyID = Provider.of<CompneyInfo>(context).id;
    final life = Provider.of<CompneyLifeProvider>(context)[compneyID];
    if (life == null) {
      return const ListTile(
        subtitle: Text("Loading..."),
        title: Text("Expires At"),
      );
    }
    final expDate = life.willExpireAt;
    if (expDate != null) {
      return ListTile(
        title: const Text("Expires At"),
        trailing: Text(expDate.formateDate(name: true)),
        subtitle: Text("${durationFromNow(expDate.dateTime)} left"),
      );
    }
    final delDate = life.willBeDeletedAt;
    if (delDate != null) {
      return ListTile(
        title: const Text("Will Be Deleted At"),
        trailing: Text(delDate.formateDate(name: true)),
        subtitle: Text(
          "In ${durationFromNow(delDate.dateTime)} Compney will be deleted if not actived again",
        ),
      );
    }

    return ListTile(
      title: const Text("Expires At"),
      trailing: Text(life.everGreen ? "**" : "!?"),
    );
  }
}

String durationFromNow(DateTime dateTime) {
  final days = dateTime.difference(DateTime.now()).inDays;
  if (days > 30) return "${days ~/ 30} months";
  return "$days days";
}
