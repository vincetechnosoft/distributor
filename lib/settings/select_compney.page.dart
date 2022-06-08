import 'package:distributor/auth/auth.dart';

import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/layout/routes.dart';
import 'package:distributor/providers/location.dart';

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
    final b2b = configDocProvider.doc?.distributor;
    if (b2b == null) {
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
          final compney = b2b.elementAt(index);
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
        itemCount: b2b.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const _CreateCompney(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CreateCompney extends StatefulWidget {
  const _CreateCompney({Key? key}) : super(key: key);

  @override
  State<_CreateCompney> createState() => _CreateCompneyState();
}

class _CreateCompneyState extends State<_CreateCompney> {
  final name = TextEditingController();
  var loading = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Compney"),
      content: ListView(shrinkWrap: true, children: [
        if (loading) const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            autofocus: !loading,
            readOnly: loading,
            controller: name,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: "Name",
              suffix: GestureDetector(
                onTap: () {
                  name.text = "";
                },
                child: const Icon(Icons.clear),
              ),
            ),
          ),
        ),
      ]),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancle"),
        ),
        TextButton(
          onPressed: loading ? null : makeCompney,
          child: const Text("Create"),
        )
      ],
    );
  }

  void makeCompney() async {
    setState(() {
      loading = true;
    });
    final res = await CompneyInfo(name.text).makeChanges();
    if (mounted) {
      if (res != null) {
        setState(() {
          loading = false;
        });
        res.showAlertDialog(context: context);
      } else {
        Navigator.pop(context);
      }
    }
  }
}
