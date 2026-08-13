import 'package:flutter/material.dart';

Future<T> lockScreenOnFuture<T>(
  BuildContext context, {
  required Future<T> future,
  Function? onError,
}) {
  showDialog(
    context: context,
    builder: (context) => Container(color: Colors.black26),
  );
  return future.then(
    (value) {
      Navigator.of(context).pop();
      return value;
    },
    onError: (error, stackTrace) {
      Navigator.of(context).pop();
      onError?.call();
    },
  );
}
