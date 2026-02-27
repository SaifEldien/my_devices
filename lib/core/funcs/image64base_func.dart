import 'dart:convert';

import 'package:flutter/cupertino.dart';
ImageProvider provide64baseImage(String imgSource) {
  try {
    return MemoryImage(base64Decode(imgSource));
  } catch (e) {
    return const AssetImage('assets/images/defaultProfilePicture.jpg');
  }
}
