// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:jack_components/util/cryptojs_encryption_decryption.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';

// import 'package:jack_components/util/change_to_encrypted.dart';
// import 'package:jack_components/jack_components.dart';

// class JackQRScanResult {
//   final String scannedValue;
//   final Map<String, dynamic> actualValue;

//   final bool decrypt;

//   /// ## API
//   /// decrypt -> bool (This is to decide successful or failed qr scanner)
//   /// scannedValue -> is the encrypted base64 code
//   /// actualValue -> is the decrypted value
//   JackQRScanResult({
//     required this.scannedValue,
//     required this.actualValue,
//     required this.decrypt,
//   });
// }

// class JackQRCameraNotUsed extends StatefulWidget {
//   final String securePassword;
//   final bool passNTP;
//   final bool networkStatus;
//   final Color? borderColor;
//   final double? borderWidth;
//   final Color? overlayColor;
//   final double? borderRadius;
//   final double? borderLength;
//   final double? scanArea;
//   final Text? title;
//   final Color? resultColor;

//   /// ## API
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
//   ///         resultColor: Colors.white,
//   ///         scanArea: 250,
//   ///       ),
//   ///     ),
//   ///   ).then((value) {
//   ///     final data = value as JackQRScanResult;
//   ///     print(data.data);
//   ///   });
//   /// ```
//   const JackQRCameraNotUsed({
//     Key? key,
//     required this.securePassword,
//     required this.passNTP,
//     required this.networkStatus,
//     this.borderColor,
//     this.borderWidth,
//     this.overlayColor,
//     this.borderRadius,
//     this.borderLength,
//     this.scanArea,
//     this.title,
//     this.resultColor,
//   }) : super(key: key);

//   @override
//   State<StatefulWidget> createState() => _JackQRCameraState();
// }

// class _JackQRCameraState extends State<JackQRCameraNotUsed> {
//   JackQRScanResult? result;
//   QRViewController? controller;
//   late double scanArea;
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'JackQR');

//   /// encrypted value
//   late JackEncryptData encryptData;

//   @override
//   void initState() {
//     encryptData = JackEncryptData(securekey: widget.securePassword);
//     super.initState();
//   }

//   // In order to get hot reload to work we need to pause the camera if the platform
//   // is android, or resume the camera if the platform is iOS.
//   @override
//   void reassemble() {
//     super.reassemble();
//     // if (Platform.isAndroid) {
//     //   controller!.pauseCamera();
//     // }
//     // controller!.resumeCamera();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // we check how width or tall the device is and change the scanArea and overlay accordingly.
//     scanArea = (MediaQuery.of(context).size.width < 400 ||
//             MediaQuery.of(context).size.height < 400)
//         ? 200.0
//         : 300.0;
//     return Container(
//       color: Colors.amber,
//       child: SafeArea(
//         child: Scaffold(
//           body: Stack(
//             children: [
//               _buildQrView(context),
//               Positioned(
//                 top: 8,
//                 left: 15,
//                 child: Container(
//                   height: 60,
//                   width: 60,
//                   // decoration: BoxDecoration(
//                   //   color: const Color.fromARGB(92, 0, 0, 0),
//                   //   borderRadius: BorderRadius.circular(50),
//                   // ),
//                   alignment: Alignment.center,
//                   child: IconButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                     icon: const Icon(
//                       Icons.arrow_back_ios_new_rounded,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//               // Positioned(
//               //   top: (MediaQuery.of(context).size.height / 2) -
//               //       ((scanArea / 2) + (Platform.isAndroid ? 100 : 50)),
//               //   child: Container(
//               //     width: MediaQuery.of(context).size.width,
//               //     alignment: Alignment.center,
//               //     child: widget.title ??
//               //         const Text(
//               //           'Scan QR code to proceed WOW Point',
//               //           textAlign: TextAlign.center,
//               //         ),
//               //   ),
//               // ),
//               Positioned(
//                 top: (MediaQuery.of(context).size.height / 2) +
//                     ((scanArea / 2) + (Platform.isAndroid ? 50 : 10)),
//                 child: Container(
//                   width: MediaQuery.of(context).size.width,
//                   alignment: Alignment.center,
//                   child: IconButton(
//                     onPressed: () async {
//                       await controller?.toggleFlash();
//                       setState(() {});
//                     },
//                     icon: const Icon(
//                       Icons.flashlight_on_outlined,
//                       size: 30,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),

//               /// this is to visual check out
//               // if (result != null && result!.decrypt)
//               //   Positioned(
//               //     bottom: 50,
//               //     child: Container(
//               //       width: MediaQuery.of(context).size.width,
//               //       alignment: Alignment.bottomCenter,
//               //       child: Column(
//               //         mainAxisSize: MainAxisSize.min,
//               //         children: [
//               //           Text(
//               //             result!.code.toString(),
//               //             style: const TextStyle(color: Colors.green),
//               //           ),
//               //           Text(
//               //             result!.dateString.toString(),
//               //             style: TextStyle(
//               //                 color: result!.now
//               //                             .difference(result!.date)
//               //                             .inSeconds >
//               //                         15
//               //                     ? Colors.red
//               //                     : Colors.green),
//               //           ),
//               //         ],
//               //       ),
//               //     ),
//               //   ),
//               // if (result != null && !result!.decrypt)
//               //   Positioned(
//               //     bottom: 50,
//               //     child: Container(
//               //       width: MediaQuery.of(context).size.width,
//               //       alignment: Alignment.bottomCenter,
//               //       child: Text(
//               //         result!.normalCode!,
//               //         style: const TextStyle(
//               //           color: Colors.red,
//               //         ),
//               //         textAlign: TextAlign.center,
//               //       ),
//               //     ),
//               //   )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildQrView(BuildContext context) {
//     // To ensure the Scanner view is properly sizes after rotation
//     // we need to listen for Flutter SizeChanged notification and update controller
//     return QRView(
//       key: qrKey,
//       onQRViewCreated: (controller) => _onQRViewCreated(controller, context),
//       overlay: QrScannerOverlayShape(
//         overlayColor: widget.overlayColor ?? const Color.fromRGBO(0, 0, 0, 80),
//         borderColor: widget.borderColor ?? Colors.purple,
//         borderRadius: widget.borderRadius ?? 10,
//         borderLength: widget.borderLength ?? 30,
//         borderWidth: widget.borderWidth ?? 10,
//         cutOutSize: widget.scanArea ?? scanArea,
//       ),
//       onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
//     );
//   }

//   void _onQRViewCreated(
//       QRViewController controller, BuildContext context) async {
//     setState(() {
//       this.controller = controller;
//     });

//     controller.scannedDataStream.listen((scanData) async {
//       if (scanData.code != null) {
//         final data = await evaluation(scanData);
//         controller.pauseCamera();
//         controller.dispose();
//         controller.stopCamera();
//         if (!mounted) return;
//         Navigator.of(context).pop(data);
//         // setState(() {
//         //   result = data;
//         // });
//       }
//     });
//     if (Platform.isAndroid) {
//       controller.resumeCamera();
//     }
//   }

//   Future<JackQRScanResult> evaluation(Barcode scanData) async {
//     try {
//       final actualValue = encryptData
//           .decryptFernet(changeToEncrypted(base64Decode(scanData.code!)));
//       final decode = jsonDecode(actualValue);
//       if (widget.passNTP) {
//         /// passs
//         return JackQRScanResult(
//           scannedValue: scanData.code!,
//           actualValue: decode,
//           decrypt: true,
//         );
//       } else if (!widget.passNTP && widget.networkStatus) {
//         return JackQRScanResult(
//           scannedValue: scanData.code!,
//           actualValue: decode,
//           decrypt: true,
//         );
//       } else {
//         /// can't scan ,network required
//         return JackQRScanResult(
//           scannedValue: scanData.code!,
//           actualValue: {},
//           decrypt: false,
//         );
//       }
//     } catch (e) {
//       try {
//         final actualValue =
//             decryptAESCryptoJS(scanData.code!, widget.securePassword);
//         final data = jsonDecode(actualValue);
//         return JackQRScanResult(
//           scannedValue: scanData.code!,
//           actualValue: data,
//           decrypt: true,
//           // message: "Set time automatically in your settings.",
//         );
//       } catch (e) {
//         return JackQRScanResult(
//           scannedValue: scanData.code!,
//           actualValue: {},
//           decrypt: false,
//           // message: "Set time automatically in your settings.",
//         );
//       }
//     }
//   }

//   void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
//     log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
//     if (!p) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('no Permission')),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
// }

// // Expanded(
// //               flex: 1,
// //               child: FittedBox(
// //                 fit: BoxFit.contain,
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                   children: <Widget>[
// //                     if (result != null)
// //                       Text(
// //                           'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
// //                     else
// //                       const Text('Scan a code'),
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       crossAxisAlignment: CrossAxisAlignment.center,
// //                       children: <Widget>[
// //                         Container(
// //                           margin: const EdgeInsets.all(8),
// //                           child: ElevatedButton(
// //                               onPressed: () async {
// //                                 await controller?.toggleFlash();
// //                                 setState(() {});
// //                               },
// //                               child: FutureBuilder(
// //                                 future: controller?.getFlashStatus(),
// //                                 builder: (context, snapshot) {
// //                                   return Text('Flash: ${snapshot.data}');
// //                                 },
// //                               )),
// //                         ),
// //                         Container(
// //                           margin: const EdgeInsets.all(8),
// //                           child: ElevatedButton(
// //                               onPressed: () async {
// //                                 await controller?.flipCamera();
// //                                 setState(() {});
// //                               },
// //                               child: FutureBuilder(
// //                                 future: controller?.getCameraInfo(),
// //                                 builder: (context, snapshot) {
// //                                   if (snapshot.data != null) {
// //                                     return Text(
// //                                         'Camera facing ${describeEnum(snapshot.data!)}');
// //                                   } else {
// //                                     return const Text('loading');
// //                                   }
// //                                 },
// //                               )),
// //                         )
// //                       ],
// //                     ),
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       crossAxisAlignment: CrossAxisAlignment.center,
// //                       children: <Widget>[
// //                         Container(
// //                           margin: const EdgeInsets.all(8),
// //                           child: ElevatedButton(
// //                             onPressed: () async {
// //                               await controller?.pauseCamera();
// //                             },
// //                             child: const Text('pause',
// //                                 style: TextStyle(fontSize: 20)),
// //                           ),
// //                         ),
// //                         Container(
// //                           margin: const EdgeInsets.all(8),
// //                           child: ElevatedButton(
// //                             onPressed: () async {
// //                               await controller?.resumeCamera();
// //                             },
// //                             child: const Text('resume',
// //                                 style: TextStyle(fontSize: 20)),
// //                           ),
// //                         )
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             )
