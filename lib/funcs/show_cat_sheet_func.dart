import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/devices_provider.dart';

void showCategoriesSheet(BuildContext context,TextEditingController categoryController) {
  final categories = context.read<DeviceProvider>().devices.map((device) => device.category).toSet().toList();

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return ListView.separated(
        itemCount: categories.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            title: Text(category),
            onTap: () {
              categoryController.text = category;
              Navigator.pop(context);
            },
          );
        },
      );
    },
  );
}
