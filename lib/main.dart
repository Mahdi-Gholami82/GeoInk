import 'package:flutter/material.dart';
import 'package:mapify/pages/home.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';

final httpClient = RetryClient(Client());

void main() {
  runApp(
    MaterialApp(
      home: HomePage(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          // ···
          brightness: Brightness.light,
        ),
      ),
    ),
  );
}
