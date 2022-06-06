import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:flutter/material.dart';

class AppEntryPage extends StatelessWidget {
  const AppEntryPage({Key? key, required this.entry}) : super(key: key);
  final Entry entry;

  @override
  Widget build(BuildContext context) {
    final compneyDoc = DocProvider.of<CompneyDoc>(context);
    final productDoc = DocProvider.of<ProductDoc>(context);
    return EntryPage(
      entry: entry,
      showOptions: true,
      compneyDoc: compneyDoc,
      productDoc: productDoc,
    );
  }
}
