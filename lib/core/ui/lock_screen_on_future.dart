import 'package:flutter/material.dart';

Future<T> lockScreenOnFuture<T>(BuildContext context, Future<T> future) {
  showDialog(
    context: context,
    builder: (context) => Container(color: Colors.black26),
  );
  return future.then((value) {
    Navigator.of(context).pop();
    return value;
  });
}
