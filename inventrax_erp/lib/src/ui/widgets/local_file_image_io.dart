import 'dart:io';

import 'package:flutter/material.dart';

Widget? buildLocalFileImage(
  String? path, {
  required double width,
  required double height,
  BoxFit fit = BoxFit.cover,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  if (path == null || path.isEmpty) return null;
  return Image.file(
    File(path),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: errorBuilder,
  );
}
