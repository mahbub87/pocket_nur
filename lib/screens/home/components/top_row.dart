import 'package:flutter/material.dart';
import '../../../controllers/home_controller.dart';
import 'package:provider/provider.dart';

class TopRow extends StatelessWidget {
  const TopRow({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(controller.hijriDate, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(controller.location, style: TextStyle(
          fontWeight: FontWeight.w500,
          color: controller.hasError ? Colors.red : null,
        )),
      ],
    );
  }
}
