import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class BaseWidget extends StatelessWidget {
  final Widget child;
  
  const BaseWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Theme(
      data: themeProvider.currentTheme,
      child: child,
    );
  }
}