import 'package:flutter/material.dart';

Future<T> lockScreenOnFuture<T>(
  OverlayState overLayState, {
  required Future<T> Function() job,
  Function? onError,
}) {
  final overLayEntry = OverlayEntry(
    builder: (context) =>
        const ModalBarrier(dismissible: false, color: Colors.black26),
  );

  overLayState.insert(overLayEntry);
  return job().then(
    (value) async {
      overLayEntry.remove();
      return value;
    },
    onError: (error, stackTrace) async {
      overLayEntry.remove();
      onError?.call();
    },
  );
}
