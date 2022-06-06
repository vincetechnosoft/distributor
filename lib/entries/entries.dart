export 'bought_entry.dart';
export 'buyin_payment.dart';
export 'sold_entry.dart';
export 'sellout_payment.dart';
export 'return_boxes_entry.dart';
export 'wastage_entry.dart';
export 'wallet_changes_entry.dart';

import 'package:bmi_b2b_package/bmi_b2b_package.dart';

import 'package:flutter/material.dart';

Widget entryTypeToIcon(EntryType entryType) {
  switch (entryType) {
    case EntryType.wasted:
      return const Combine2Icons(
        subMain: Icons.change_circle_sharp,
        main: Icons.remove_shopping_cart_rounded,
      );
    case EntryType.sell:
      return const Combine2Icons(
        subMain: Icons.upload_rounded,
        main: Icons.local_grocery_store_rounded,
      );
    case EntryType.buy:
      return const Combine2Icons(
        subMain: Icons.get_app_rounded,
        main: Icons.local_grocery_store_rounded,
      );
    case EntryType.buyInPayment:
      return const Combine2Icons(
        subMain: Icons.upload_rounded,
        main: Icons.currency_rupee_rounded,
      );
    case EntryType.sellOutPayment:
      return const Combine2Icons(
        subMain: Icons.get_app_rounded,
        main: Icons.currency_rupee_rounded,
      );
    case EntryType.wallet:
      return const Combine2Icons(
        subMain: Icons.change_circle_sharp,
        main: Icons.currency_rupee_rounded,
      );
    case EntryType.returnBoxes:
      return const Combine2Icons(
        subMain: Icons.get_app_rounded,
        main: Icons.card_travel_rounded,
      );
  }
}
