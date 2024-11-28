import 'package:flutter/material.dart';

void navigatePR({required BuildContext context, required Widget screen}) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => screen),
  );
}

void navigateBack(BuildContext context) {
  Navigator.pop(context);
}

void navigateAndRemove(
    {required BuildContext context, required Widget screen}) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => screen),
    (Route<dynamic> route) => false,
  );
}
