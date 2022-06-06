import 'package:distributor/auth/auth.dart';

import 'package:distributor/layout/drawer.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({
    Key? key,
    required this.errorObj,
    required this.title,
    required this.fromGateWay,
    this.drawer,
    this.reset,
  }) : super(key: key);
  final Object errorObj;
  final String title;
  final void Function()? reset;
  final bool? drawer;
  final bool fromGateWay;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: reset == null
            ? null
            : [
                IconButton(
                  onPressed: reset,
                  icon: const Icon(Icons.restore),
                )
              ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 20),
              child: Text(
                "Something Went Wrong",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Text(
                (errorObj.toString()).toString(),
                style: Theme.of(context).textTheme.headline5?.merge(
                      TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
              ),
            ),
            SettingsWidgit.signOut<MyAuthUser>(),
          ],
        ),
      ),
      drawer: (drawer ?? !Navigator.canPop(context)) ? const MyDrawer() : null,
    );
  }
}
