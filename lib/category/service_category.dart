import 'package:flutter/material.dart';

class ServiceCategory {
  final String name;
  final int? serviceCount;
  final IconData? icon;
  final Color? color;
  final Color? iconColor;

  ServiceCategory({
    required this.name,
    this.serviceCount,
    this.icon,
    this.color,
    this.iconColor,
  });
}