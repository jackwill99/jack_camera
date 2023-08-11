import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
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
  // final GlobalKey qrKey = GlobalKey(debugLabel: 'JackQR');

  ScanController controller = ScanController();

  @override
  void initState() {
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
              controller.pause();
              if (!mounted) return;
              Navigator.of(context).pop(qrValue);
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
              padding: EdgeInsets.only(bottom: 60.h),
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

  @override
  void dispose() {
    super.dispose();
  }

  Future<String?> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String? qrResult = await Scan.parse(pickedFile.path);
      return qrResult;
    }
    return null;
  }
}
