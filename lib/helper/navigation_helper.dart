import 'package:flutter/material.dart';

void navigateTo({required BuildContext context, required Widget route}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => route));
}

void navigatePR(BuildContext context, Widget screen) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => screen),
  );
}

void navigateBack(BuildContext context) {
  Navigator.pop(context);
}

void navigateAndRemove(BuildContext context, Widget screen) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => screen),
    (Route<dynamic> route) => false,
  );
}

void navigateAndReplace(BuildContext context, Widget screen) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => screen),
  );
}

void navigateAndReplaceAll(BuildContext context, Widget screen) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => screen),
    (Route<dynamic> route) => false,
  );
}
