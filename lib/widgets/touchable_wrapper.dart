import 'package:flutter/material.dart';
import 'package:mini_projet/pages/services/vibration_service.dart';


class TouchableWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool vibrateOnTap;

  const TouchableWrapper({
    Key? key,
    required this.child,
    required this.onTap,
    this.vibrateOnTap = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        if (vibrateOnTap) await VibrationService.vibrate();
        onTap();
      },
      child: child,
    );
  }
}