import 'package:flutter/material.dart';

void showLoading(BuildContext context, bool show) {
  show == true
      ? showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: SizedBox(
              height: 50,
              width: 50,
              child: const CircularProgressIndicator()),
        ),
      );
    },
  )
      : Navigator.of(context, rootNavigator: true).pop('dialog');
}
