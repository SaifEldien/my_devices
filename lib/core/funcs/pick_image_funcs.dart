import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
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
              title: Text('camera'.tr()),
              onTap: () async {
                final picker = ImagePicker();
                final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);
                if (!context.mounted) return;
                bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
                Color toolbarWidgetColor = Colors.white;
                Color backgroundColor = isDarkMode ? Color(0xFF1E1E1E) : Colors.white;
                CroppedFile? image = await ImageCropper().cropImage(
                  sourcePath: pickedFile!.path,
                  compressFormat: ImageCompressFormat.jpg,
                  compressQuality: 100,
                  uiSettings: [
                    AndroidUiSettings(
                      toolbarTitle: context.locale.languageCode == 'ar' ? 'قص الصورة' : 'Crop Image',
                      initAspectRatio: CropAspectRatioPreset.original,
                      lockAspectRatio: false,
                      toolbarColor: Color(0xFF121212),
                      statusBarLight: !isDarkMode,
                      toolbarWidgetColor: toolbarWidgetColor,
                      backgroundColor: backgroundColor,
                      activeControlsWidgetColor: isDarkMode
                          ? Colors.amber
                          : Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                );
                if (image != null) {
                  if (!context.mounted) return;
                  Navigator.pop(context, [image.path]);
                } else {
                  if (!context.mounted) return;
                  Navigator.pop(context, null);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: Text('gallery'.tr()),
              onTap: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  allowMultiple: true,
                );
                if (result != null && result.files.length == 1) {
                    final PlatformFile pickedFile = result.files.first;
                    if (!context.mounted) return;
                    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
                    Color toolbarWidgetColor = Colors.white;
                    Color backgroundColor = isDarkMode ? Color(0xFF1E1E1E) : Colors.white;
                    CroppedFile? image = await ImageCropper().cropImage(
                      sourcePath: pickedFile.path!,
                      compressFormat: ImageCompressFormat.jpg,
                      compressQuality: 100,
                      uiSettings: [
                        AndroidUiSettings(
                          toolbarTitle: context.locale.languageCode == 'ar' ? 'قص الصورة' : 'Crop Image',
                          initAspectRatio: CropAspectRatioPreset.original,
                          lockAspectRatio: false,
                          toolbarColor: Color(0xFF121212),
                          statusBarLight: !isDarkMode,
                          toolbarWidgetColor: toolbarWidgetColor,
                          backgroundColor: backgroundColor,
                          activeControlsWidgetColor: isDarkMode
                              ? Colors.amber
                              : Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context, [image!.path]);
                    return;
                }
                if (result != null) {
                  final paths = result.files
                      .where((file) => file.path != null)
                      .map((file) => file.path!)
                      .toList();
                  if (!context.mounted) return;
                  Navigator.pop(context, paths);
                } else {
                  if (!context.mounted) return;
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
