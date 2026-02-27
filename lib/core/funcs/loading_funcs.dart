import 'package:flutter/material.dart';

void showLoading(BuildContext context, bool show) {
  if (show) {
    showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop:  false,
        child: Center(
          child: SizedBox(
              height: 50,
              width: 50,
              child: const CircularProgressIndicator()),
        ),
      );
    },
  );

  }else {
    Navigator.of(context, rootNavigator: true).pop('dialog');
  }
}
