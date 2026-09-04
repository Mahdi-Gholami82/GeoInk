import 'package:flutter/material.dart';

class SettingsTitle extends StatelessWidget {
  const SettingsTitle({super.key, required this.title});

  final Widget title;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var scaler = MediaQuery.of(context).textScaler;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: scaler.scale(24),
        bottom: scaler.scale(10),
        start: 24,
        end: 24,
      ),
      child: DefaultTextStyle(
        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        child: title,
      ),
    );
  }
}
