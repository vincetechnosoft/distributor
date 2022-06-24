// import 'package:distributor/auth/auth.dart';
// import 'package:bmi_b2b_package/bmi_b2b_package.dart';

// import 'package:flutter/material.dart';

// class MaintenancePage extends StatelessWidget {
//   const MaintenancePage({Key? key, required this.maintenance})
//       : super(key: key);

//   final Maintenance maintenance;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Under Maintenance"),
//         actions: [SettingsWidgit.signOut<MyAuthUser>()],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: ListView(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 15, bottom: 20),
//               child: Text(
//                 "App's Server Are under some big changes",
//                 textAlign: TextAlign.center,
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//             ),
//             const Divider(),
//             Center(
//               child: Text(
//                 maintenance.message,
//                 style: Theme.of(context).textTheme.headline5?.merge(
//                       const TextStyle(color: Colors.pinkAccent),
//                     ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
