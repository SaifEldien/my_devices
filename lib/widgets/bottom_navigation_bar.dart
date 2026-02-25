import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final List <Widget> children;
  const CustomBottomNavigationBar({super.key, required this.children});
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: children,
        ),
      ),
    );
  }
}

Widget buildNavItem({
  required IconData icon,
  required String title,
  required isActive,
  VoidCallback? onTap,
}) {
  return InkWell(
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    borderRadius: BorderRadius.all(Radius.circular(50)),
    onTap: () => onTap==null ? (){} : onTap(),
    child: Padding(
      padding: const EdgeInsets.all(3),
      child: Wrap(
        direction: Axis.vertical,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(icon, color: isActive ? Colors.lightBlue : Colors.grey, size: 30),
          Text(title, style: TextStyle(color: isActive ? Colors.lightBlue : Colors.grey)),
        ],
      ),
    ),
  );
}
