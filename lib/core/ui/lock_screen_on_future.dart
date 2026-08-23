import 'package:flutter/material.dart';

Future<T> lockScreenOnFuture<T>(
  BuildContext context, {
  required Future<T> Function() job,
  Function? onError,
}) {
  final overLayEntry = OverlayEntry(
    builder: (context) =>
        const ModalBarrier(dismissible: false, color: Colors.black26),
  );

  Overlay.of(context).insert(overLayEntry);
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
