// import 'package:flutter/material.dart';
// import 'package:madlyvpn/models/tab_model.dart';
// class TabWidget extends StatelessWidget {
//   final TabModel tab;
//   final VoidCallback onClose;
//
//   TabWidget({required this.tab, required this.onClose});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.symmetric(horizontal: 4),
//       child: InkWell(
//         onTap: () {
//           // You can implement the logic to switch to the selected tab here
//         },
//         child: Padding(
//           padding: EdgeInsets.all(8),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   tab.title,
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               IconButton(
//                 icon: Icon(Icons.close),
//                 onPressed: onClose,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }