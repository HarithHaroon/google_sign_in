import 'package:flutter/material.dart';

@immutable
class UserData {
  final String id;
  final String name;

  const UserData({
    required this.id,
    required this.name,
  });
}
