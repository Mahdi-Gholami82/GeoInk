import 'package:flutter/material.dart';

Future<T?> showSimpleProgress<T>(BuildContext context) => showDialog(
  context: context,
  builder: (context) {
    return Container(
      color: Colors.black38,
      child: Center(child: CircularProgressIndicator()),
    );
  },
);
