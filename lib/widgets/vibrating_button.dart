import 'package:flutter/material.dart';
import 'package:mini_projet/pages/services/vibration_service.dart';


class VibratingElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;

  const VibratingElevatedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style,
      onPressed: () async {
        await VibrationService.vibrate();
        onPressed();
      },
      child: child,
    );
  }
}

class VibratingTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;

  const VibratingTextButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: style,
      onPressed: () async {
        await VibrationService.vibrate();
        onPressed();
      },
      child: child,
    );
  }
}

class VibratingOutlinedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;

  const VibratingOutlinedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: style,
      onPressed: () async {
        await VibrationService.vibrate();
        onPressed();
      },
      child: child,
    );
  }
}