import 'package:distributor/layout/drawer.dart';
import 'package:flutter/material.dart';

class PremissionRequiredPage extends StatelessWidget {
  const PremissionRequiredPage({Key? key, required this.title})
      : super(key: key);
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? "Unknown"),
      ),
      drawer: Navigator.canPop(context) ? null : const MyDrawer(),
      body: Center(
        child: Text(
          "Owner level permission required",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
