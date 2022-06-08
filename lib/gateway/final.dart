import 'package:distributor/auth/auth.dart';
import 'package:distributor/gateway/maintenance.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/providers/location.dart';
import 'package:distributor/settings/select_compney.page.dart';
import 'package:distributor/utils/utils.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class FinalGateWay extends StatelessWidget {
  const FinalGateWay.builder(this.child, {Key? key}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyAuthUser>(context);
    final configDocProvider = Provider.of<DocProvider<ConfigDoc>>(context);
    final maintenance = configDocProvider.doc?.maintenance;
    if (maintenance != null && maintenance.applyToUs) {
      return MaintenancePage(maintenance: maintenance);
    }

    final compneyDocProvider = Provider.of<DocProvider<CompneyDoc>>(context);
    final productDocProvider = Provider.of<DocProvider<ProductDoc>>(context);
    final stateDocProvider = Provider.of<DocProvider<StateDoc>>(context);
    final locationProvider = Provider.of<LocationProvider>(context);

    if (configDocProvider.doc == null ||
        compneyDocProvider.doc == null ||
        productDocProvider.doc == null ||
        stateDocProvider.doc == null) {
      if (locationProvider.compneyID == null) {
        if (user.isDev) return const SelectCompneyPage(fromGateWay: true);
        return const ProfilePage(fromGateWay: true);
      }
      if (configDocProvider.loading ||
          compneyDocProvider.loading ||
          productDocProvider.loading ||
          stateDocProvider.loading) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Getting Data"),
            actions: [SettingsWidgit.signOut<MyAuthUser>()],
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      return ErrorPage(
        fromGateWay: true,
        errorObj: compneyDocProvider.error ??
            productDocProvider.error ??
            stateDocProvider.error ??
            "Compney Info Document Not Found",
        title: "Server Side Error",
        drawer: false,
        reset: locationProvider.reset,
      );
    }
    if (compneyDocProvider.doc?.action.disabled == true && !user.isDev) {
      return ErrorPage(
        fromGateWay: true,
        title: "Compney is disabled",
        errorObj:
            "This compney is automatecly disabled, Contact to software provider",
        drawer: false,
        reset: locationProvider.reset,
      );
    }

    return child;
  }
}
