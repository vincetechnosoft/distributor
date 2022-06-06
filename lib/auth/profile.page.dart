import 'package:distributor/auth/auth.dart';
import 'package:distributor/layout/drawer.dart';
import 'package:distributor/providers/location.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key, required this.fromGateWay}) : super(key: key);
  final bool fromGateWay;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyAuthUser>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final configDoc = Provider.of<DocProvider<ConfigDoc>>(context).doc!;
    final compneyID = locationProvider.compneyID;
    final compneyIDs = user.compneyIDs;
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Page")),
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
                  final info = configDoc.getCompney(e);
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
            if (!user.isDev && compneyIDs.isEmpty)
              ..._noAccess(context, fromGateWay),
          ],
        ),
      ),
    );
  }
}

List<Widget> _noAccess(BuildContext context, bool showLogOut) {
  return [
    if (showLogOut) SettingsWidgit.signOut<MyAuthUser>(),
    Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 20),
      child: Text(
        "No Access",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    ),
    const Divider(),
    Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Text(
        "To Create your acount on \nBusiness Management Interface (BMI)\nPatel Panth @Contact:",
        style: Theme.of(context).textTheme.headline5?.merge(
              TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.only(top: 50),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.phone),
        onPressed: () async {
          const url = "tel:+919173373578";
          if (await canLaunchUrlString(url)) {
            await launchUrlString(url);
          } else {
            throw 'Could not launch $url';
          }
        },
        style: ElevatedButton.styleFrom(primary: Colors.pinkAccent),
        label: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text("+91 9173373578"),
        ),
      ),
    ),
  ];
}
