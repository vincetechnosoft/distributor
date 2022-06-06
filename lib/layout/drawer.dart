import 'package:distributor/auth/auth.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/layout/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: const [
          _Header(),
          _PageTo(mainPage: MainPage.home),
          _PageTo(mainPage: MainPage.seller),
          _PageTo(mainPage: MainPage.buyers),
          Divider(),
          _PageTo(mainPage: MainPage.inventory),
          _PageTo(mainPage: MainPage.current),
          _PageTo(mainPage: MainPage.report),
          Divider(),
          _PageTo(mainPage: MainPage.profile),
          _PageTo(mainPage: MainPage.settings),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyAuthUser>(context);
    final name = DocProvider.of<CompneyDoc>(context, listen: false).name;
    return DrawerHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.hasRoleOf(),
            style: Theme.of(context).textTheme.headline3,
          ),
          const Spacer(),
          Text(
            name,
            style: Theme.of(context).textTheme.headline5,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _PageTo extends StatelessWidget {
  const _PageTo({Key? key, required this.mainPage}) : super(key: key);
  final MainPage mainPage;

  @override
  Widget build(BuildContext context) {
    final mainRoute = MainRoute.get(mainPage);
    final user = Provider.of<MyAuthUser>(context);
    final settings = Provider.of<RouteSettings>(context);
    if (mainRoute.route == (settings.name ?? MainRoute.defaultRoute.route)) {
      return ListTile(
        selected: true,
        leading: Icon(mainRoute.icon),
        title: Text(mainRoute.name),
        onTap: () {
          Navigator.pop(context);
        },
      );
    }
    return ListTile(
      leading: Icon(mainRoute.icon),
      title: Text(mainRoute.name),
      onTap: () {
        Navigator.pop(context);
        Navigator.popAndPushNamed(context, mainRoute.route);
      },
      enabled: mainRoute.ownerOnly ? user.hasOwnerPermission : true,
    );
  }
}
