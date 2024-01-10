// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jack_camera/src/security/encrypt_decrypt/change_to_encrypted.dart';
import 'package:jack_camera/src/security/encrypt_decrypt/encrypt%20_data.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scan/scan.dart';

class JackQRScanResult {
  final String scannedValue;
  final Map<String, dynamic> actualValue;

  final bool decrypt;

  /// ## API
  /// decrypt -> bool (This is to decide successful or failed qr scanner)
  /// scannedValue -> is the encrypted base64 code
  /// actualValue -> is the decrypted value
  JackQRScanResult({
    required this.scannedValue,
    required this.actualValue,
    required this.decrypt,
  });
}

class JackQRCamera extends StatefulWidget {
  final String securePassword;
  final bool passNTP;
  final bool networkStatus;
  final VoidCallback? permissionModel;

  /// is u want to show image picker, u must need permissionModel
  final bool showImagePicker;
  final Color? overlayColor;

  /// custom scan area, if set to 1.0, will scan full area
  final double? scanArea;
  final Text? title;

  /// ## API
  ///
  /// is u want to show image picker, u must need permissionModel
  ///
  /// ```dart
  ///   Navigator.of(context, rootNavigator: true).push(
  ///     JackPageTransition(
  ///       widget: JackQRCamera(
  ///         networkStatus: network.online,
  ///         passNTP: network.passNTP,
  ///         securePassword: "SabanaWOWmeDoublePlusApplication",
  ///         title: const Text(
  ///           'Scan QR code to proceed WOW Point',
  ///           style: TextStyle(
  ///             color: Colors.white,
  ///           ),
  ///         ),
  ///         scanArea: 0.5,
  ///       ),
  ///     ),
  ///   ).then((value) {
  ///     final data = value as JackQRScanResult;
  ///     print(data.data);
  ///   });
  /// ```
  const JackQRCamera({
    Key? key,
    required this.securePassword,
    required this.passNTP,
    required this.networkStatus,
    this.permissionModel,
    required this.showImagePicker,
    this.overlayColor,
    this.scanArea,
    this.title,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _JackQRCameraState();
}

class _JackQRCameraState extends State<JackQRCamera> {
  JackQRScanResult? result;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'JackQR');

  ScanController controller = ScanController();

  /// encrypted value
  late JackEncryptData encryptData;

  @override
  void initState() {
    encryptData = JackEncryptData(securekey: widget.securePassword);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ScanView(
            controller: controller,
            scanAreaScale: widget.scanArea ?? .7,
            scanLineColor: widget.overlayColor ?? Colors.green.shade400,
            onCapture: (qrValue) async {
              final data = await evaluation(qrValue, true);
              controller.pause();
              if (!mounted) return;
              Navigator.of(context).pop(data);
            },
          ),
          Column(
            children: [
              30.verticalSpace,
              GestureDetector(
                onTap: () {
                  controller.pause();
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 16),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              30.verticalSpace,
              if (widget.title != null) widget.title!,
            ],
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.showImagePicker)
                    Container(
                      height: 50,
                      width: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white),
                      child: IconButton(
                        onPressed: () async {
                          final photoRequest = Platform.isIOS
                              ? await Permission.photos.request()
                              : await Permission.storage.request();
                          if (photoRequest.isDenied) return;
                          if (photoRequest.isPermanentlyDenied) {
                            widget.permissionModel?.call();
                          } else {
                            final data = await _getImage();
                            if (data == null) return;
                            controller.pause();
                            if (!mounted) return;
                            Navigator.of(context).pop(data);
                          }
                        },
                        icon: const Icon(
                          CupertinoIcons.photo_fill_on_rectangle_fill,
                          size: 25,
                        ),
                      ),
                    ),
                  if (widget.showImagePicker) 20.horizontalSpace,
                  Container(
                    height: 50,
                    width: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white),
                    child: IconButton(
                      onPressed: () async {
                        controller.toggleTorchMode();
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.flashlight_on_outlined,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// this is to visual check out
          // if (result != null && result!.decrypt)
          //   Positioned(
          //     bottom: 50,
          //     child: Container(
          //       width: MediaQuery.of(context).size.width,
          //       alignment: Alignment.bottomCenter,
          //       child: Column(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           Text(
          //             result!.code.toString(),
          //             style: const TextStyle(color: Colors.green),
          //           ),
          //           Text(
          //             result!.dateString.toString(),
          //             style: TextStyle(
          //                 color: result!.now
          //                             .difference(result!.date)
          //                             .inSeconds >
          //                         15
          //                     ? Colors.red
          //                     : Colors.green),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // if (result != null && !result!.decrypt)
          //   Positioned(
          //     bottom: 50,
          //     child: Container(
          //       width: MediaQuery.of(context).size.width,
          //       alignment: Alignment.bottomCenter,
          //       child: Text(
          //         result!.normalCode!,
          //         style: const TextStyle(
          //           color: Colors.red,
          //         ),
          //         textAlign: TextAlign.center,
          //       ),
          //     ),
          //   )
        ],
      ),
    );
  }

  Future<JackQRScanResult> evaluation(String scanData, bool checkNTP) async {
    try {
      debugPrint("----------------------start decode----------------------");
      final actualValue =
          encryptData.decryptFernet(changeToEncrypted(base64Decode(scanData)));
      final decode = jsonDecode(actualValue);
      return JackQRScanResult(
        scannedValue: scanData,
        actualValue: decode,
        decrypt: true,
      );
      // debugPrint("----------------------decode success----------------------");
      // if (checkNTP) {
      //   debugPrint("----------------------checkNTP true----------------------");
      //   var now = await NTPApi.getNtp(context);
      //   if (now == null) {
      //     debugPrint("----------------------now is null----------------------");
      //     return JackQRScanResult(
      //       scannedValue: scanData,
      //       actualValue: {},
      //       decrypt: false,
      //       // message: "Set time automatically in your settings.",
      //     );
      //   }

      //   final dateTimeNow = DateTime.parse(now);
      //   final previousData = DateTime.parse(decode['date']);

      //   if (dateTimeNow.difference(previousData).inSeconds > 15) {
      //     debugPrint(
      //         "----------------------difference is lower than 15----------------------");
      //     return JackQRScanResult(
      //       scannedValue: scanData,
      //       actualValue: {},
      //       decrypt: false,
      //       // message: "Set time automatically in your settings.",
      //     );
      //   } else {
      //     debugPrint("----------------------pass----------------------");
      //     return JackQRScanResult(
      //       scannedValue: scanData,
      //       actualValue: decode,
      //       decrypt: true,
      //     );
      //   }
      // } else {
      //   debugPrint(
      //       "----------------------checkNTP false----------------------");
      //   return JackQRScanResult(
      //     scannedValue: scanData,
      //     actualValue: decode,
      //     decrypt: true,
      //   );
      // }

      // if (widget.passNTP) {
      //   /// passs
      //   return JackQRScanResult(
      //     scannedValue: scanData,
      //     actualValue: decode,
      //     decrypt: true,
      //   );
      // } else if (!widget.passNTP && widget.networkStatus) {
      //   return JackQRScanResult(
      //     scannedValue: scanData,
      //     actualValue: decode,
      //     decrypt: true,
      //   );
      // } else {
      //   /// can't scan ,network required
      //   return JackQRScanResult(
      //     scannedValue: scanData,
      //     actualValue: {},
      //     decrypt: false,
      //   );
      // }
    } catch (e) {
      debugPrint(
          "----------------------decryption error----------------------");
      try {
        debugPrint(
            "----------------------start crypto js----------------------");
        print(scanData);
        final actualValue = decryptAESCryptoJS(scanData, widget.securePassword);
        print(actualValue);
        final data = jsonDecode(actualValue);
        print(data);
        debugPrint(
            "----------------------crypto js success----------------------");
        return JackQRScanResult(
          scannedValue: scanData,
          actualValue: data,
          decrypt: true,
          // message: "Set time automatically in your settings.",
        );
      } catch (e) {
        return JackQRScanResult(
          scannedValue: scanData,
          actualValue: {},
          decrypt: false,
          // message: "Set time automatically in your settings.",
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<JackQRScanResult?> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String? qrResult = await Scan.parse(pickedFile.path);
      if (qrResult == null) return null;
      return await evaluation(qrResult, false);
    }
    return null;
  }
}

class NTPApi {
  static Future<String?> getNtp(BuildContext context) async {
    String? check;

    final baseDio = Dio(
      BaseOptions(
        baseUrl: "https://www.wowme.tech/api",
        connectTimeout: const Duration(milliseconds: 6000),
        receiveTimeout: const Duration(milliseconds: 6000),
      ),
    );
    baseDio.options.headers['Content-Type'] = "application/json";
    try {
      final Response response =
          await baseDio.get("/v1/user/application/server/time");
      final responseData = response.data as Map<String, dynamic>;

      if (!responseData['error']) {
        check = responseData['data'];
      } else {
        check = null;
      }
    } catch (e) {
      check = null;
    }

    return check;
  }
}

class NTPDate with ChangeNotifier {
  DateTime? now;

  void updateNTPDate(String? value) {
    if (value != null) {
      now = DateTime.parse(value);
    }
    now = null;

    notifyListeners();
  }
}

extension on int {
  SizedBox get verticalSpace => SizedBox(
        height: toDouble(),
      );
  SizedBox get horizontalSpace => SizedBox(
        width: toDouble(),
      );
}
