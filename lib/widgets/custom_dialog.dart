import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_devices/funcs/loading_funcs.dart';

import '../funcs/show_toast_func.dart';

Widget _buildDialogButton(
  BuildContext context,
  String text,
  Color bgColor,
  Color textColor,
  Function onPressed,
) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 10)],
    ),
    child: TextButton(
      onPressed: () => onPressed(),
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ),
  );
}

class CustomDialog extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Function onAccept;
  final bool? isDelete;
  final String title;
  const CustomDialog({
    super.key,
    required this.icon,
    required this.color,
    required this.onAccept,
    this.isDelete, required this.title,
  });
  @override
  State<CustomDialog> createState() =>
      _CustomDialogState(icon: icon, color: color, onAccept: onAccept, isDelete: isDelete, title: title);
}

class _CustomDialogState extends State<CustomDialog> {
  final IconData icon;
  final Color color;
  final Function onAccept;
  final bool? isDelete;
  final String title;
  late bool isPasswordValid;

  _CustomDialogState({
    required this.icon,
    required this.color,
    required this.onAccept,
    required this.isDelete,
    required this.title
  });
  @override
  void initState() {
    isPasswordValid = !(isDelete == true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 20,
      child: AnimatedContainer(
        width: 400,
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.white),
            const SizedBox(height: 20),
             Text(
              title,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
             Text(
              'are_you_sure'.tr(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDialogButton(context, 'no'.tr(), Colors.white.withOpacity(0.6), Colors.black, () {
                  Navigator.of(context).pop();
                }),
                const SizedBox(width: 20),
                _buildDialogButton(
                  context,
                  'yes'.tr(),
                  isPasswordValid == false ? Colors.grey : Colors.greenAccent,
                  Colors.black,
                  () async {
                    await onAccept();
                    showToast(context, 'done'.tr());
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

 Future<void> showCustomDialog(BuildContext context, {required Function onAccept, required IconData icon, required Color color, required String title}) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return CustomDialog(
        icon: icon,
        color: color,
        title: title,
        onAccept: () async {
          try {
            showLoading(context, true);
            await onAccept();
            showLoading(context, false);
          } catch (e) {
            showLoading(context, false);
            showToast(context, e.toString());
          }
        },
      );
    },
  );
}
