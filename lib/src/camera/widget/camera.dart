import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// This will return imageUintBase and imagePath
///
/// First is base64 image data and
/// Second is the FilePath of the image
class JackCamera extends StatefulWidget {
  static const routeName = 'camera-page';
  final List<CameraDescription> camera;

  const JackCamera({
    Key? key,
    required this.camera,
  }) : super(key: key);

  @override
  State<JackCamera> createState() => _JackCameraState();
}

class _JackCameraState extends State<JackCamera> with WidgetsBindingObserver {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRearCameraSelected = true;

  /// zoom level
  double _minAvailableZoom = 1.0;

  // u can set as max as zoom level of ur device in zoomLevelSetup function,
  final double _maxAvailableZoom = 5.0;
  double _currentZoomLevel = 1.0;

  /// Exposure control
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;

  @override
  void initState() {
    // Hide the status bar
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
    cameraInit(widget.camera[_isRearCameraSelected ? 0 : 1]);
  }

  // Future<void> _requestAccess() async {
  //   final status = await Permission.camera.request();
  //   if (!status.isGranted) {
  //     if (!mounted) return;
  //     Navigator.of(context).pop();
  //   }
  // }

  /// Initialization Camera
  Future<void> cameraInit(CameraDescription cameraDescription) async {
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      cameraDescription,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();

    zoomLevelSetup();
    exposureControlSetup();
  }

  /// after intialization camera, setCameraZoom
  Future<void> zoomLevelSetup() async {
    await _initializeControllerFuture;
    await Future.wait([
      /// u can set as max as zoom level of ur device,
      /// but i set up at zoom level at most 5
      // _controller.getMaxZoomLevel().then((value) {
      //   setState(() {
      //     _maxAvailableZoom = value;
      //   });
      // }),
      _controller.getMinZoomLevel().then((value) {
        setState(() {
          _minAvailableZoom = value;
        });
      }),
    ]);
  }

  /// set Exposure control
  Future<void> exposureControlSetup() async {
    await _initializeControllerFuture;
    await Future.wait([
      _controller
          .getMinExposureOffset()
          .then((value) => _minAvailableExposureOffset = value),
      _controller
          .getMaxExposureOffset()
          .then((value) => _maxAvailableExposureOffset = value),
    ]);
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print("----------------------$AppLifecycleState----------------------");

    /// Running the camera on any device is considered a memory-hungry task,
    /// so how you handle freeing up the memory resources, and when that occurs, is important.
    final CameraController cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (!cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      cameraInit(cameraController.description);
    }
  }

  Future<void> _takeCapture() async {
    // Take the Picture in a try / catch block. If anything goes wrong,
    // catch the error.
    print('hay');
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      // Attempt to take a picture and get the file `image`
      // where it was saved.
      final image = await _controller.takePicture();

      if (!mounted) return;

      // If the picture was taken, display it on a new screen.
      final productImage = await image.readAsBytes();
      if (!mounted) return;
      // context.read<CameraProvider>().updateUintBase(productImage);
      // context.read<CameraProvider>().updateFilePath(File(image.path));
      print(image.path);
      Navigator.of(context)
          .pop({"imageUintBase": productImage, "imagePath": File(image.path)});
    } catch (e) {
      // If an error occurs, log the error to the console.
      print("----------------------Camera can't Capture----------------------");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text('Take a Picture'),
        //   centerTitle: true,
        // ),
        // You must wait until the controller is initialized before displaying the
        // camera preview. Use a FutureBuilder to display a loading spinner until the
        // controller has finished initializing.
        body: Stack(
          children: [
            Column(
              children: [
                /* +++++++++++++++++ Top Level Stack +++++++++++++++++ */
                Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    border: Border.all(color: Colors.purple),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 10.0,
                        ),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Close',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /* ---------------------- Camera View ----------------------  */
                Expanded(
                  child: FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // If the Future is complete, display the preview.

                        return Container(
                          decoration: const BoxDecoration(color: Colors.black),
                          child: Center(
                            child: CameraPreview(_controller),
                          ),
                        );
                      } else {
                        // Otherwise, display a loading indicator.
                        // return const Center(child: CircularProgressIndicator());
                        return Container(
                          color: Colors.black87,
                        );
                      }
                    },
                  ),
                ),

                /* +++++++++++++++++ Bottom Level Stack +++++++++++++++++ */
                Center(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 140,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          border: Border.all(color: Colors.red)),
                      child: Column(
                        children: [
                          /* --------------------- zoom level control -----------------------  */
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: _currentZoomLevel,
                                  min: _minAvailableZoom,
                                  max: _maxAvailableZoom,
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.white30,
                                  onChanged: (value) async {
                                    setState(() {
                                      _currentZoomLevel = value;
                                    });
                                    await _controller.setZoomLevel(value);
                                  },
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${_currentZoomLevel.toStringAsFixed(1)}x',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          /* +++++++++++++++++ camera bottom control +++++++++++++++++ */
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 50,
                              ),
                              InkWell(
                                onTap: () async {
                                  await _takeCapture();
                                },
                                child: const SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Icon(
                                    Icons.fiber_manual_record,
                                    color: Colors.white,
                                    size: 75,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isRearCameraSelected =
                                        !_isRearCameraSelected;
                                  });
                                  cameraInit(widget
                                      .camera[_isRearCameraSelected ? 0 : 1]);
                                },
                                child: const Icon(
                                  Icons.flip_camera_ios_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            /* +++++++++++++++++ exposure view +++++++++++++++++ */
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.63,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.green)),
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${_currentExposureOffset.toStringAsFixed(1)}x',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      RotatedBox(
                        quarterTurns: 3,
                        child: SizedBox(
                          height: 30,
                          width: MediaQuery.of(context).size.height * 0.5,
                          child: Slider(
                            value: _currentExposureOffset,
                            min: _minAvailableExposureOffset,
                            max: _maxAvailableExposureOffset,
                            activeColor: Colors.white,
                            inactiveColor: Colors.white30,
                            onChanged: (value) async {
                              setState(() {
                                _currentExposureOffset = value;
                              });
                              await _controller.setExposureOffset(value);
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
