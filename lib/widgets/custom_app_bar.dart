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
        Text(title),
      ],
    ),
    elevation: 0,
  );
}
