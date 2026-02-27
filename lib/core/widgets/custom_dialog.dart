import 'package:my_devices/core/funcs/conver_numbers_to_arabic.dart';

import '../core.dart';

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
    this.isDelete,
      required this.title,
    });
    @override
    State<CustomDialog> createState() => _CustomDialogState();
  }

  class _CustomDialogState extends State<CustomDialog> {
    _CustomDialogState();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final IconData icon = widget.icon;
    final Color color = widget.color;
    final Function onAccept = widget.onAccept;
    final String title = widget.title;

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
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'are_you_sure'.tr(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDialogButton(context, 'no'.tr(), Colors.white.withValues(alpha: 0.6), Colors.black, () {
                  Navigator.of(context).pop();
                }),
                const SizedBox(width: 20),
                  _buildDialogButton(context, 'yes'.tr(), Colors.greenAccent, Colors.black, () async {
                  await onAccept();
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showCustomDialog(
  BuildContext context, {
  required Function onAccept,
  required IconData icon,
  required Color color,
  required String title,
   isShowToast = true
}) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return CustomDialog(
        icon: icon,
        color: color,
        title: title,
        onAccept: () async {
          showLoading(context, true);
          try {
            await onAccept();
            if (isShowToast) {
              if (!context.mounted) return;
              showToast(
                context.locale.languageCode == "ar" ? convertEnglishNumbersToArabic("${'done'.tr()} $title ${"success".tr()}") : "${'done'.tr()} $title ${"success".tr()}"
              );
            }
          }
          catch (e) {
            if (isShowToast) {
              if (!context.mounted) return;
              if (context.locale.languageCode == "ar") {
                showToast(convertEnglishNumbersToArabic("${"failed".tr()} $title ${"fail".tr()}"),isError: true,isLongDuration: true);
              } else {
                showToast("${"failed".tr()} $title",isError: true,isLongDuration: true);
              }

            }
          }
          if (!context.mounted) return;
          showLoading(context, false);
        },
      );
    },
  );
}
