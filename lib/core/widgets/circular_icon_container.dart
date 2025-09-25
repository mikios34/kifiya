import 'package:flutter/material.dart';

class CircularIconContainer extends StatelessWidget {
  final String icon;
  final double? height;
  final double? width;
  const CircularIconContainer({
    super.key,
    required this.icon,
    this.height = 20,
    this.width = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Image.asset(icon, height: height, width: width),
    );
  }
}
