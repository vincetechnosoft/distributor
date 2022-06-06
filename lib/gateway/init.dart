import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/providers/location.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

ChangeNotifierProxyProvider<LocationProvider, DocProvider<T>> _provideDoc<T>(
  T Function(RawMap) parser,
  String Function(String compneyID) pathBuilder,
) {
  return ChangeNotifierProxyProvider(
    create: (_) => DocProvider(parse: parser),
    update: (_, loc, doc) {
      doc ??= DocProvider(parse: parser);
      final id = loc.compneyID;
      if (id == null) {
        doc.changePath(null);
      } else {
        doc.changePath(pathBuilder(id));
      }
      return doc;
    },
  );
}

class InitGateWay extends StatelessWidget {
  const InitGateWay.builder(this.child, {Key? key}) : super(key: key);
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => DocProvider(
                parse: ConfigDoc.fromJson, initialPath: "CONFIG/B2B")),
        ChangeNotifierProxyProvider(
            create: LocationProvider.init, update: LocationProvider.update),
        _provideDoc(CompneyDoc.fromJson, (id) => "B2B/$id"),
        _provideDoc(ProductDoc.fromJson, (id) => "B2B/$id/DATA/PRODUCTS"),
        _provideDoc(StateDoc.fromJson, (id) => "B2B/$id/DATA/STATE"),
      ],
      child: child,
    );
  }
}
