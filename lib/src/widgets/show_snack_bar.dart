import 'package:flutter/material.dart';

void showSnackBar({
  required BuildContext context,
  required String text,
  Color? color,
}) {
  final snackBar = SnackBar(
    content: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 18,
      ),
    ),
    dismissDirection: DismissDirection.horizontal,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 10,
    duration: const Duration(milliseconds: 1500),
    backgroundColor: color ?? Theme.of(context).primaryColor,
    margin: const EdgeInsets.all(20),
    behavior: SnackBarBehavior.floating,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
