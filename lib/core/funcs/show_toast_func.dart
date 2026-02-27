import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast(String message , { bool isError = false ,bool isLongDuration = false}) {
  Fluttertoast.showToast(
      msg:   "$message ${isError ? "✘" : "✓"}",
      toastLength: isLongDuration ? Toast.LENGTH_LONG :  Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0
  );}