// import 'package:CarRescue/src/presentation/view/car_owner_view/car_view/car_view.dart';

// import 'package:CarRescue/src/presentation/view/car_owner_view/car_view/car_view.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:CarRescue/src/configuration/frontend_configs.dart';
// import 'package:CarRescue/src/presentation/elements/custom_text.dart';
// import 'package:CarRescue/src/presentation/view/car_owner_view/history/history_view.dart';

// class DrawerView extends StatelessWidget {
//   const DrawerView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 240,
//       child: Drawer(
//         backgroundColor: Colors.white,
//         child: ListView(
//           // Important: Remove any padding from the ListView.
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                 ),
//                 child: Column(
//                   children: [
//                     CircleAvatar(
//                       radius: 43,
//                       child: Image.asset("assets/images/profile.png"),
//                     ),
//                     const SizedBox(
//                       height: 5,
//                     ),
//                     CustomText(
//                       text: 'Hieu Phan',
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     const SizedBox(
//                       height: 5,
//                     ),
//                     CustomText(
//                       text: '+84 34567890',
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ],
//                 )),
//             SizedBox(
//               height: 40,
//               child: ListTile(
//                 minLeadingWidth: 2,
//                 leading: SvgPicture.asset(
//                   color: FrontendConfigs.kIconColor,
//                   "assets/svg/home_icon.svg",
//                   height: 20,
//                   width: 20,
//                 ),
//                 title: CustomText(
//                   text: 'Trang chủ',
//                   color: Colors.black87,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ),
//             SizedBox(
//               height: 40,
//               child: ListTile(
//                 minLeadingWidth: 2,
//                 leading: SvgPicture.asset(
//                   "assets/svg/person_icon.svg",
//                   color: FrontendConfigs.kIconColor,
//                   height: 18,
//                   width: 18,
//                 ),
//                 title: CustomText(
//                   text: 'Cá nhân',
//                   color: Colors.black87,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ),
//             SizedBox(
//               height: 40,
//               child: ListTile(
//                 minLeadingWidth: 2,
//                 leading: SvgPicture.asset(
//                   "assets/svg/car_icon.svg",
//                   // ignore: deprecated_member_use
//                   color: FrontendConfigs.kIconColor,
//                   height: 20,
//                   width: 20,
//                 ),
//                 title: CustomText(
//                   text: 'Xe của tôi',
//                   color: Colors.black87,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 // onTap: () {
//                 //   Navigator.push(context,
//                 //       MaterialPageRoute(builder: (context) => CarListView()));
//                 // },
//               ),
//             ),
//             SizedBox(
//               height: 40,
//               child: ListTile(
//                 minLeadingWidth: 2,
//                 leading: SvgPicture.asset(
//                   "assets/svg/wallet_icon.svg",
//                   color: FrontendConfigs.kIconColor,
//                   height: 16,
//                   width: 16,
//                 ),
//                 title: CustomText(
//                   text: 'Ví của tôi',
//                   color: Colors.black87,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ),
//             SizedBox(
//               height: 40,
//               child: ListTile(
//                 minLeadingWidth: 2,
//                 leading: SvgPicture.asset(
//                   "assets/svg/trip_history.svg",
//                   color: FrontendConfigs.kIconColor,
//                   height: 20,
//                   width: 20,
//                 ),
//                 title: CustomText(
//                   text: 'Lịch sử đơn hàng',
//                   color: Colors.black87,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 onTap: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const HistoryView()));
//                 },
//               ),
//             ),
//             SizedBox(
//               height: 40,
//               child: ListTile(
//                 minLeadingWidth: 2,
//                 leading: SvgPicture.asset(
//                   "assets/svg/notification_icon.svg",
//                   color: FrontendConfigs.kIconColor,
//                   height: 20,
//                   width: 20,
//                 ),
//                 title: CustomText(
//                   text: 'Thông báo',
//                   color: Colors.black87,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ),
//             // SizedBox(
//             //   height: 40,
//             //   child: ListTile(
//             //     minLeadingWidth: 2,
//             //     leading: SvgPicture.asset(
//             //       "assets/svg/language.svg",
//             //       color: FrontendConfigs.kIconColor,
//             //       height: 20,
//             //       width: 20,
//             //     ),
//             //     title: CustomText(
//             //       text: 'Language',
//             //       color: FrontendConfigs.kIconColor,
//             //     ),
//             //     onTap: () {
//             //       Navigator.pop(context);
//             //     },
//             //   ),
//             // ),
//             SizedBox(
//               height: 40,
//               child: ListTile(
//                 minLeadingWidth: 2,
//                 leading: SvgPicture.asset(
//                   "assets/svg/privacy.svg",
//                   color: FrontendConfigs.kIconColor,
//                   height: 20,
//                   width: 20,
//                 ),
//                 title: CustomText(
//                   text: 'Chính sách riêng tư',
//                   color: Colors.black87,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ),
//             SizedBox(
//               height: 40,
//               child: ListTile(
//                 minLeadingWidth: 2,
//                 leading: SvgPicture.asset(
//                   "assets/svg/help_center.svg",
//                   color: FrontendConfigs.kIconColor,
//                   height: 20,
//                   width: 20,
//                 ),
//                 title: CustomText(
//                   text: 'Trung tâm hỗ trợ',
//                   color: Colors.black87,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ),
//             SizedBox(
//               height: 40,
//               child: ListTile(
//                 minLeadingWidth: 2,
//                 leading: SvgPicture.asset(
//                   "assets/svg/exit.svg",
//                   color: Colors.red,
//                   height: 20,
//                   width: 20,
//                 ),
//                 title: CustomText(
//                   text: 'Đăng xuất',
//                   color: Colors.red,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
