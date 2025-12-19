import 'package:flutter/material.dart';

class InkWellTextButton extends StatelessWidget {
  const InkWellTextButton({
    super.key,
    required this.onTap,
    required this.title,
    this.minWidth = 100,
  });

  final double minWidth;
  final Function() onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 100),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          alignment: Alignment.center,
          child: Row(
            spacing: 4,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
              Icon(Icons.expand_more),
            ],
          ),
        ),
      ),
    );
  }
}
