import 'package:distributor/providers/location.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyAuthUser extends B2bAuthUser {
  static MyAuthUser? _inUse;
  static MyAuthUser? get inUse => _inUse;

  MyAuthUser(User user, Map<String, Object?> claims) : super(user, claims) {
    _inUse = this;
  }

  @override
  String? get compneyIdInUse => compneyIDs.length == 1
      ? compneyIDs.first
      : LocationProvider.inUse?.compneyID;
}
