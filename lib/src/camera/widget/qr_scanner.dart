// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import "dart:io";

// import "package:device_info_plus/device_info_plus.dart";
// import "package:flutter/cupertino.dart";
// import "package:flutter/material.dart";
// import "package:image_picker/image_picker.dart";
// import "package:mobile_scanner/mobile_scanner.dart";
// import "package:permission_handler/permission_handler.dart";
// // import "package:scan/scan.dart";

// class JackQRCamera extends StatefulWidget {
//   final VoidCallback? permissionModel;

//   /// is u want to show image picker, u must need permissionModel
//   final bool showImagePicker;
//   final Color? overlayColor;

//   /// custom scan area, if set to 1.0, will scan full area
//   final double? scanArea;
//   final Text? title;

//   /// ## API
//   ///
//   /// is u want to show image picker, u must need permissionModel
//   ///
//   /// ```dart
//   ///   Navigator.of(context, rootNavigator: true).push(
//   ///     JackPageTransition(
//   ///       widget: JackQRCamera(
//   ///         networkStatus: network.online,
//   ///         passNTP: network.passNTP,
//   ///         securePassword: "SabanaWOWmeDoublePlusApplication",
//   ///         title: const Text(
//   ///           'Scan QR code to proceed WOW Point',
//   ///           style: TextStyle(
//   ///             color: Colors.white,
//   ///           ),
//   ///         ),
//   ///         scanArea: 0.5,
//   ///       ),
//   ///     ),
//   ///   ).then((value) {
//   ///     final data = value as JackQRScanResult;
//   ///     print(data.data);
//   ///   });
//   /// ```
//   const JackQRCamera({
//     required this.showImagePicker,
//     Key? key,
//     this.permissionModel,
//     this.overlayColor,
//     this.scanArea,
//     this.title,
//   }) : super(key: key);

//   @override
//   State<StatefulWidget> createState() => _JackQRCameraState();
// }

// class _JackQRCameraState extends State<JackQRCamera> {
//   // JackQRScanResult? result;
//   final GlobalKey qrKey = GlobalKey(debugLabel: "JackQR");

//   MobileScannerController controller = MobileScannerController();

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           ScanView(
//             controller: controller,
//             scanAreaScale: widget.scanArea ?? .7,
//             scanLineColor: widget.overlayColor ?? Colors.green.shade400,
//             onCapture: (qrValue) async {
//               // controller.pause();
//               if (!context.mounted) return;
//               Navigator.of(context).pop(qrValue);
//             },
//           ),
//           Column(
//             children: [
//               const SizedBox(height: 30),
//               GestureDetector(
//                 onTap: () {
//                   // controller.pause();
//                   Navigator.of(context).pop();
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 8, right: 16),
//                   child: Align(
//                     alignment: Alignment.topLeft,
//                     child: Container(
//                       padding: const EdgeInsets.all(8),
//                       margin: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.transparent,
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: Colors.grey),
//                       ),
//                       child: const Icon(
//                         Icons.arrow_back_ios_new_rounded,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               if (widget.title != null) widget.title!,
//             ],
//           ),

//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 60),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   if (widget.showImagePicker)
//                     Container(
//                       height: 50,
//                       width: 50,
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(30),
//                         color: Colors.white,
//                       ),
//                       child: IconButton(
//                         onPressed: () async {
//                           final plugin = DeviceInfoPlugin();
//                           AndroidDeviceInfo? android;
//                           if (Platform.isAndroid) {
//                             android = await plugin.androidInfo;
//                           }
//                           final photoRequest = Platform.isIOS
//                               ? await Permission.photos.request()
//                               : android != null && android.version.sdkInt < 33
//                                   ? await Permission.storage.request()
//                                   : PermissionStatus.granted;
//                           if (photoRequest.isDenied) return;
//                           if (photoRequest.isPermanentlyDenied) {
//                             widget.permissionModel?.call();
//                           } else {
//                             final data = await _getImage();
//                             if (data == null) return;
//                             // controller.pause();
//                             if (!context.mounted) return;
//                             Navigator.of(context).pop(data);
//                           }
//                         },
//                         icon: const Icon(
//                           CupertinoIcons.photo_fill_on_rectangle_fill,
//                           size: 25,
//                         ),
//                       ),
//                     ),
//                   if (widget.showImagePicker) const SizedBox(width: 20),
//                   Container(
//                     height: 50,
//                     width: 50,
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(30),
//                       color: Colors.white,
//                     ),
//                     child: IconButton(
//                       onPressed: () async {
//                         controller.toggleTorchMode();
//                         setState(() {});
//                       },
//                       icon: const Icon(
//                         Icons.flashlight_on_outlined,
//                         size: 25,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           /// this is to visual check out
//           // if (result != null && result!.decrypt)
//           //   Positioned(
//           //     bottom: 50,
//           //     child: Container(
//           //       width: MediaQuery.of(context).size.width,
//           //       alignment: Alignment.bottomCenter,
//           //       child: Column(
//           //         mainAxisSize: MainAxisSize.min,
//           //         children: [
//           //           Text(
//           //             result!.code.toString(),
//           //             style: const TextStyle(color: Colors.green),
//           //           ),
//           //           Text(
//           //             result!.dateString.toString(),
//           //             style: TextStyle(
//           //                 color: result!.now
//           //                             .difference(result!.date)
//           //                             .inSeconds >
//           //                         15
//           //                     ? Colors.red
//           //                     : Colors.green),
//           //           ),
//           //         ],
//           //       ),
//           //     ),
//           //   ),
//           // if (result != null && !result!.decrypt)
//           //   Positioned(
//           //     bottom: 50,
//           //     child: Container(
//           //       width: MediaQuery.of(context).size.width,
//           //       alignment: Alignment.bottomCenter,
//           //       child: Text(
//           //         result!.normalCode!,
//           //         style: const TextStyle(
//           //           color: Colors.red,
//           //         ),
//           //         textAlign: TextAlign.center,
//           //       ),
//           //     ),
//           //   )
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   Future<String?> _getImage() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       final String? qrResult = await Scan.parse(pickedFile.path);
//       return qrResult;
//     }
//     return null;
//   }
// }
