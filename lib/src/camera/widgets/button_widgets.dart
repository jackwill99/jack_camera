import "package:flutter/material.dart";
import "package:mobile_scanner/mobile_scanner.dart";

class ToggleFlashlightButton extends StatelessWidget {
  const ToggleFlashlightButton({required this.controller, super.key});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return const SizedBox.shrink();
        }

        switch (state.torchState) {
          case TorchState.off:
            return IconButton(
              iconSize: 32.0,
              icon: const Icon(Icons.flashlight_off_outlined),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.on:
            return IconButton(
              iconSize: 32.0,
              icon: const Icon(
                Icons.flashlight_on_outlined,
              ),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.unavailable:
            return const IconButton(
              iconSize: 32.0,
              icon: Icon(
                Icons.flashlight_off_outlined,
                color: Colors.grey,
              ),
              onPressed: null,
            );
        }
      },
    );
  }
}
