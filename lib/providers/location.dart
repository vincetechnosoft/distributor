import 'package:distributor/auth/auth.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor/main.dart';
import 'package:flutter/material.dart';

class LocationProvider extends ChangeNotifier {
  var _compneyID = preferences.getString("compneyID");

  static LocationProvider? _inUse;
  static LocationProvider? get inUse => _inUse;

  LocationProvider.init(BuildContext context) {
    _inUse = this;
  }

  factory LocationProvider.update(
    BuildContext context,
    MyAuthUser user,
    LocationProvider? previous,
  ) {
    previous ??= LocationProvider.init(context);
    final compneyID = previous._compneyID;
    if (compneyID != null && !user.hasCompney(compneyID)) previous.reset();
    return previous;
  }

  String? get compneyID => _compneyID;

  void changeCompney(CompneyInfo compneyInfo) {
    if (compneyInfo.id == _compneyID) return;
    preferences.setString("compneyID", compneyInfo.id);
    _compneyID = compneyInfo.id;
    notifyListeners();
  }

  void reset() {
    if (_compneyID == null) return;
    preferences.remove("compneyID");
    _compneyID = null;
    notifyListeners();
  }
}
