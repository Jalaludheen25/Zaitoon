import 'package:flutter/material.dart';

void navigateTo({required BuildContext context, required Widget route}) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => route));
}

// navigate  pushandremoveuntil
void navigatePRTo(BuildContext context, Widget screen) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => screen),
    (Route<dynamic> route) => false,
  );
}
