import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<List<String>?> showImageSourcePicker(BuildContext context) async {
  return await showModalBottomSheet<List<String>>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title:  Text('camera'.tr()),
              onTap: () async {
                final picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                );

                if (image != null) {
                  Navigator.pop(context, [image.path]);
                } else {
                  Navigator.pop(context, null);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title:  Text('gallery'.tr()),
              onTap: () async {
                FilePickerResult? result =
                await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  allowMultiple: true,
                );

                if (result != null) {
                  final paths = result.files
                      .where((file) => file.path != null)
                      .map((file) => file.path!)
                      .toList();

                  Navigator.pop(context, paths);
                } else {
                  Navigator.pop(context, null);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
