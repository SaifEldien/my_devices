import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final IconData? icon;
  final bool? isSearch;
  final Function? onSearchChanged;
  final Function? switchSearchBar;
  final List<Widget>? actions;
  const CustomAppBar({
    super.key,
    required this.title,
    this.icon,
    this.actions,
    this.isSearch,
    this.switchSearchBar,
    this.onSearchChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          //backgroundColor: Colors.white,
          title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: icon != null
              ? SizedBox()
              : IconButton(
                  icon: Icon(icon ?? Icons.arrow_back_ios),
                  onPressed: () {
                    if (icon == null) {
                      Navigator.pop(context);
                    }
                  },
                ),
          actions: isSearch == true
              ? [
                  IconButton(
                    onPressed: () {
                      switchSearchBar == null ? null : switchSearchBar!();
                    },
                    icon: Icon(Icons.search),
                  ),
                ]
              : actions,
        ),
      ],
    );
  }
}
