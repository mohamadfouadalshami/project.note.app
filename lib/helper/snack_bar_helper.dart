import 'package:flutter/material.dart';

void showSuccessMessage(String message, BuildContext context) {
  // Implement your logic to show a success message (e.g., a Snackbar)
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green,
    ),
  );
}

void showErrorMessage(String message, BuildContext context) {
  // Implement your logic to show an error message (e.g., a Snackbar)
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.red,
    ),
  );
}
