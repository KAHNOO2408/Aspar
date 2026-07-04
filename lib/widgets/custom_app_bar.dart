import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

PreferredSizeWidget buildCustomAppBar({
  required String title,
  required BuildContext context,
}) {
  return AppBar(
    title: Row(
      children: [
        SvgPicture.asset(
          'assets/logo.svg',
          width: 40,
          height: 40,
        ),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ],
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    backgroundColor: Colors.transparent,
    elevation: 0,
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F6BF5), Color(0xFF2B3FBE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
  );
}
