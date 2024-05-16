import "dart:async";
import "dart:io";

import "package:device_info_plus/device_info_plus.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:jack_camera/src/camera/widgets/button_widgets.dart";
import "package:jack_camera/src/camera/widgets/scanner_error_widget.dart";
import "package:jack_camera/src/camera/widgets/scanner_overlay.dart";
import "package:mobile_scanner/mobile_scanner.dart";
import "package:permission_handler/permission_handler.dart";

class JackMobileScanner extends StatefulWidget {
  const JackMobileScanner({
    this.showImagePicker = true,
    this.permissionModel,
    this.title,
    this.overlayHeight = 250,
    this.overlayWidth = 250,
    super.key,
  });

  final VoidCallback? permissionModel;
  final Text? title;

  /// If u want to show image picker, u must need permissionModel
  final bool showImagePicker;
  final double overlayWidth;
  final double overlayHeight;

  @override
  State<JackMobileScanner> createState() => _JackMobileScannerState();
}

class _JackMobileScannerState extends State<JackMobileScanner>
    with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController();

  StreamSubscription<Object?>? _subscription;

  Future<void> _scanOnImage(BuildContext context) async {
    final plugin = DeviceInfoPlugin();
    AndroidDeviceInfo? android;
    if (Platform.isAndroid) {
      android = await plugin.androidInfo;
    }
    final photoRequest = Platform.isIOS
        ? await Permission.photos.request()
        : android != null && android.version.sdkInt < 33
            ? await Permission.storage.request()
            : PermissionStatus.granted;
    if (photoRequest.isDenied) {
      return;
    }

    if (photoRequest.isPermanentlyDenied) {
      widget.permissionModel?.call();
    } else {
      final data = await _getImage();
      if (data == null) {
        return;
      }
      unawaited(controller.stop());
      if (!context.mounted) {
        return;
      }
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(data);
      }
    }
  }

  Future<String?> _getImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) {
      return null;
    }

    final BarcodeCapture? barcodes = await controller.analyzeImage(
      image.path,
    );

    if (!context.mounted) {
      return null;
    }

    return barcodes?.barcodes.first.displayValue;
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    final code = barcodes.barcodes.first.displayValue;
    unawaited(controller.stop());
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(code);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _subscription = controller.barcodes.listen(_handleBarcode);

    unawaited(controller.start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _subscription = controller.barcodes.listen(_handleBarcode);

        unawaited(controller.start());
      case AppLifecycleState.inactive:
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
    }
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
    await controller.dispose();
  }

  Widget _buildScanWindow(Rect scanWindowRect) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        // Not ready.
        if (!value.isInitialized ||
            !value.isRunning ||
            value.error != null ||
            value.size.isEmpty) {
          return const SizedBox();
        }

        return ScannerOverlay(
          width: scanWindowRect.width,
          height: scanWindowRect.height,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset.zero),
      width: widget.overlayWidth,
      height: widget.overlayHeight,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            errorBuilder: (context, error, child) {
              return ScannerErrorWidget(error: error);
            },
          ),
          _buildScanWindow(scanWindow),
          Column(
            children: [
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  unawaited(controller.stop());
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
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
            ],
          ),
          if (widget.title != null) widget.title!,
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
                        color: Colors.white,
                      ),
                      child: IconButton(
                        onPressed: () => unawaited(_scanOnImage(context)),
                        icon: const Icon(
                          CupertinoIcons.photo_fill_on_rectangle_fill,
                          size: 25,
                        ),
                      ),
                    ),
                  if (widget.showImagePicker) const SizedBox(width: 20),
                  Container(
                    height: 50,
                    width: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                    ),
                    child: ToggleFlashlightButton(
                      controller: controller,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
