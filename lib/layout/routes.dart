import 'package:distributor/auth/auth.dart';
import 'package:distributor/buyers/buyers.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/entries/entry.page.dart';
import 'package:distributor/inventory/inventory.dart';
import 'package:distributor/layout/permission_req.page.dart';
import 'package:distributor/report/report.dart';
import 'package:distributor/sellers/sellers.dart';
import 'package:distributor/settings/settings.dart';
import 'package:distributor/home/home.dart';

import 'package:flutter/material.dart';

abstract class _Route extends AppRoute<void> {
  _Route({
    required String route,
    required this.name,
    required this.ownerOnly,
    required this.page,
  }) : super(route);
  final String name;
  final Widget page;
  final bool ownerOnly;

  @override
  Widget builder({argument}) {
    if (ownerOnly) {
      if (MyAuthUser.inUse?.hasOwnerPermission != true) {
        return PremissionRequiredPage(title: name);
      }
    }
    return page;
  }
}

enum MainPage {
  home, // ✅
  profile, // ✅
  seller, // ✅
  buyers, // ✅
  inventory, // ✅
  current, // ✅
  report, // ✅
  settings, // ✅
}

class MainRoute extends _Route {
  static final defaultRoute = MainRoute._(
    icon: Icons.home,
    route: "/",
    name: "Home",
    page: const HomePage(),
    ownerOnly: false,
  );
  static final _routes = {
    MainPage.home: defaultRoute,
    MainPage.profile: MainRoute._(
      icon: Icons.portrait_rounded,
      route: "/profile",
      name: "Profile",
      page: const ProfilePage(fromGateWay: false),
      ownerOnly: false,
    ),
    MainPage.seller: MainRoute._(
      icon: Icons.shopping_cart_outlined,
      route: "/seller",
      name: "Sellers",
      page: const SellerPage(),
      ownerOnly: true,
    ),
    MainPage.buyers: MainRoute._(
      icon: Icons.store_mall_directory_outlined,
      route: "/buyers",
      name: "Buyers",
      page: const BuyerPage(),
      ownerOnly: false,
    ),
    MainPage.report: MainRoute._(
      icon: Icons.data_thresholding_rounded,
      route: "/report",
      name: "Report",
      page: const ReportOptionsPage(),
      ownerOnly: true,
    ),
    MainPage.settings: MainRoute._(
      icon: Icons.settings,
      route: "/settings",
      name: "Settings",
      page: const SettingsPage(),
      ownerOnly: false,
    ),
    MainPage.inventory: MainRoute._(
      icon: Icons.inventory,
      route: "/inventory",
      name: "Inventory",
      page: const InventoryPage(),
      ownerOnly: false,
    ),
    MainPage.current: MainRoute._(
      icon: Icons.toc_rounded,
      route: "/current",
      name: "Current Entries",
      page: const CurrentEntriesPage(),
      ownerOnly: true,
    ),
  };
  static void goTo(BuildContext context, MainPage mainPage) {
    _routes[mainPage]!.navigate(context, argument: null);
  }

  static MainRoute get(MainPage mainPage) {
    return _routes[mainPage]!;
  }

  MainRoute._({
    required this.icon,
    required String route,
    required String name,
    required Widget page,
    required bool ownerOnly,
  }) : super(route: route, name: name, page: page, ownerOnly: ownerOnly);
  final IconData icon;

  @override
  final isMainPage = true;
}

enum SecondaryPage {
  //! home page
  workerInfo, // ✅
  buyersUserInfo, // ✅
  sellerAccInfo, // ✅
  products, // ✅
  //! inventory page
  inventoryWastage, // ✅
  //! settings page
  selectCompney, // ✅
}

class SecondaryRoute extends _Route {
  static final _routes = {
    SecondaryPage.selectCompney: SecondaryRoute._(
      route: "/settings/selectCompney",
      name: "Select Compney",
      page: const SelectCompneyPage(fromGateWay: false),
      ownerOnly: true,
    ),
    SecondaryPage.workerInfo: SecondaryRoute._(
      route: "/home/workerInfo",
      name: "Compney User Info",
      page: const CompneyUserInfoPage(),
      ownerOnly: false,
    ),
    SecondaryPage.sellerAccInfo: SecondaryRoute._(
      route: "/home/sellerAccInfo",
      name: "Seller Info",
      page: const SellerInfoPage(),
      ownerOnly: false,
    ),
    SecondaryPage.buyersUserInfo: SecondaryRoute._(
      route: "/home/buyersUserInfo",
      name: "Buyer Info",
      page: const BuyerInfoPage(),
      ownerOnly: false,
    ),
    SecondaryPage.products: SecondaryRoute._(
      route: "/home/product",
      name: "Products",
      page: const ProductInfoPage(),
      ownerOnly: false,
    ),
    SecondaryPage.inventoryWastage: SecondaryRoute._(
      route: "/inventory/wastage",
      name: "Update Inventory",
      page: const CreateWastageEntryPage(),
      ownerOnly: true,
    ),
  };
  static void goTo(BuildContext context, SecondaryPage secondaryPage) {
    _routes[secondaryPage]!.navigate(context, argument: null);
  }

  static SecondaryRoute get(SecondaryPage secondaryPage) {
    return _routes[secondaryPage]!;
  }

  SecondaryRoute._({
    required String route,
    required String name,
    required Widget page,
    required bool ownerOnly,
  }) : super(route: route, name: name, page: page, ownerOnly: ownerOnly);

  @override
  final isMainPage = false;
}

class EntryRoute extends AppRoute<Entry> {
  static final instance = EntryRoute._();
  static void goTo(BuildContext context, Entry entry) {
    instance.navigate(context, argument: entry);
  }

  EntryRoute._() : super("/entry/");

  @override
  Widget? builder({Entry? argument}) {
    if (MyAuthUser.inUse?.hasOwnerPermission != true) {
      return const PremissionRequiredPage(title: "Entry Page");
    }
    if (argument == null) return null;
    return AppEntryPage(entry: argument);
  }

  @override
  final isMainPage = false;
}

class SellerRoute extends AppRoute<SellerInfo> {
  static final instance = SellerRoute._();
  static void goTo(BuildContext context, SellerInfo sellerInfo) {
    instance.navigate(context, argument: sellerInfo);
  }

  SellerRoute._() : super("/seller/status");

  @override
  final isMainPage = false;

  @override
  Widget? builder({SellerInfo? argument}) {
    if (MyAuthUser.inUse?.hasOwnerPermission != true) {
      return const PremissionRequiredPage(title: "Sellere's Entries");
    }
    if (argument == null) return null;
    return SellersEntriesPage(sellerInfo: argument);
  }
}

class BuyerRoute extends AppRoute<BuyerInfo> {
  static final instance = BuyerRoute._();
  static void goTo(BuildContext context, BuyerInfo buyerInfo) {
    instance.navigate(context, argument: buyerInfo);
  }

  BuyerRoute._() : super("/buyers/status");

  @override
  final isMainPage = false;
  @override
  Widget? builder({BuyerInfo? argument}) {
    if (MyAuthUser.inUse?.hasOwnerPermission != true) {
      return const PremissionRequiredPage(title: "Buyer's Entries");
    }
    if (argument == null) return null;
    return BuyersEntriesPage(buyerInfo: argument);
  }
}
