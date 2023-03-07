// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class JackPickCropImage {
  final List<PlatformUiSettings>? uiSettings;

  /// ## API Usage
  ///
  /// ```dart
  /// final crop = JackPickCropImage(
  ///   uiSettings: [
  ///     AndroidUiSettings(
  ///       initAspectRatio:
  ///           CropAspectRatioPreset.original,
  ///       toolbarColor:
  ///           Theme.of(context).colorScheme.secondary,
  ///       toolbarTitle: 'Edit Images',
  ///       statusBarColor:
  ///           Theme.of(context).colorScheme.secondary,
  ///       activeControlsWidgetColor:
  ///           Theme.of(context).colorScheme.primary,
  ///       cropFrameColor:
  ///           Theme.of(context).colorScheme.primary,
  ///       cropGridColor: Colors.white,
  ///       toolbarWidgetColor: Colors.black,
  ///       backgroundColor: Colors.white,
  ///       lockAspectRatio: false,
  ///     ),
  ///     IOSUiSettings(
  ///       title: 'Edit Images',
  ///     )
  ///   ],
  /// );
  /// if (Platform.isIOS) {
  ///   crop.takeAndCropFromPhotos();
  /// } else {
  ///   final result =
  ///       await crop.takeAndCropFromStorage();
  ///   print(result?.path);
  ///   /// after use of them, delete this photo
  ///   result?.deleteSync();
  /// }
  /// ```
  JackPickCropImage({required this.uiSettings});

  File? _image;
  File? _selectedFile;
  final _picker = ImagePicker();

  set setImage(File? image) {
    _image = image;
  }

  File? get getImage {
    return _image;
  }

  set setSelectedFile(File? file) {
    _selectedFile = file;
  }

  File? get getSelectedFile {
    return _selectedFile;
  }

  Future requestPermission(Permission permission) async {
    final result = await permission.request();
    return result;
  }

  Future<File?> takeAndCropFromCamera() async {
    final result = await requestPermission(Permission.camera);
    return _onStatusRequestedCamera(result);
  }

  Future<File?> takeAndCropFromStorage() async {
    final result = await requestPermission(Permission.storage);
    return _onStatusRequested(result);
  }

  Future<File?> takeAndCropFromPhotos() async {
    final result = await requestPermission(Permission.photos);
    return _onStatusRequested(result);
  }

  Future<File?> _onStatusRequested(status) async {
    /// iphone selected photo
    // PermissionStatus.limited

    /// iphone none
    /// PermissionStatus.permanentlyDenied

    /// android
    /// if tow time don't allow -> permanentlyDenied -> firstTime -> denied

    if (status == PermissionStatus.denied) return null;
    if (status == PermissionStatus.permanentlyDenied) {
      // if (Platform.isIOS) {
      //   openAppSettings();
      // } else {
      //   if (status == PermissionStatus.permanentlyDenied) {
      //     openAppSettings();
      //   }
      // }

      /// show model to go to settings
      // generalModalDialog(
      //   context: navigatorKey.currentContext!,
      //   title: "Permission Denied",
      //   desc: "You need to accept photo permission in your settings",
      // );
    } else {
      await _getImage(ImageSource.gallery);
      return _selectedFile;
    }
    return null;
  }

  Future<File?> _onStatusRequestedCamera(status) async {
    if (status == PermissionStatus.denied) return null;
    if (status == PermissionStatus.permanentlyDenied) {
      // if (Platform.isIOS) {
      //   openAppSettings();
      // } else {
      //   if (status == PermissionStatus.permanentlyDenied) {
      //     openAppSettings();
      //   }
      // }

      /// show model to go to settings
      // generalModalDialog(
      //   context: navigatorKey.currentContext!,
      //   title: "Permission Denied",
      //   desc: "You need to accept camera and photo permission in your settings",
      // );
    } else {
      await _getImage(ImageSource.camera);
      return _selectedFile;
    }
    return null;
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      requestFullMetadata: false,
    );
    if (pickedFile != null) {
      setImage = File(pickedFile.path);
    }

    if (_image != null) {
      CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: _image!.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        maxWidth: 700,
        maxHeight: 700,
        cropStyle: CropStyle.circle,
        compressFormat: ImageCompressFormat.jpg,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        uiSettings: uiSettings,
        // uiSettings: [
        //   AndroidUiSettings(
        //     initAspectRatio: CropAspectRatioPreset.original,
        //     toolbarColor: Colors.white,
        //     toolbarTitle: 'Edit Images',
        //     statusBarColor: widget.statusBarColor,
        //     activeControlsWidgetColor: widget.activeControlsWidgetColor,
        //     cropFrameColor: Colors.white,
        //     cropGridColor: Colors.white,
        //     toolbarWidgetColor: widget.toolbarWidgetColor,
        //     backgroundColor: Colors.white,
        //     lockAspectRatio: false,
        //   ),
        //   IOSUiSettings(
        //     title: 'Edit Images',
        //   )
        // ],
      );

      if (cropped != null) {
        if (_selectedFile != null && _selectedFile!.existsSync()) {
          _selectedFile!.deleteSync();
        }
        setSelectedFile = File(cropped.path);
      }
      // delete image camera
      if (source.toString() == 'ImageSource.camera' && _image!.existsSync()) {
        _image!.deleteSync();
      }
      setImage = null;
    }
  }
}
