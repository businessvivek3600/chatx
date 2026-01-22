import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';

enum SnackbarType { success, error, info, warning }

void showAppSnackbar({
  required BuildContext context,
  required SnackbarType type,
  required String description,
}) {
  switch (type) {
    case SnackbarType.success:
      CherryToast.success(
        toastDuration: Duration(milliseconds: 2500),
        height: 70,
        toastPosition: Position.top,
        displayCloseButton: false,
        description: Text(description,style: TextStyle(color: Colors.green),),
        animationType: AnimationType.fromTop,
      ).show(context);
      break;
    case SnackbarType.error:
      CherryToast.error(
        description: Text(description),
        animationType: AnimationType.fromTop,
      ).show(context);
      break;
    case SnackbarType.info:
      CherryToast.info(
        description: Text(description),
        animationType: AnimationType.fromTop,
      ).show(context);
      break;
    case SnackbarType.warning:
      CherryToast.warning(
        description: Text(description),
        animationType: AnimationType.fromTop,
      ).show(context);
      break;
  }
}

class MyButton extends StatelessWidget {
  final VoidCallback? onTab;
  final String buttonText;
  const MyButton({super.key, required this.onTab, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTab,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Text(buttonText),
    );
  }
}
