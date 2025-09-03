import 'package:flutter/material.dart';

class UIHelpers {
  // Helper method for kid-friendly messages
  static void showKidFriendlyMessage(
    BuildContext context, 
    String message, 
    Color backgroundColor, 
    {int duration = 3}
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: duration),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}