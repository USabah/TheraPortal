import 'package:flutter/material.dart';

void alertFunction(
    {required BuildContext context,
    required String title,
    required String content,
    required VoidCallback? onPressed,
    required String btnText,
    bool? isDismissable}) {
  showDialog(
    context: context,
    barrierDismissible: isDismissable ?? true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        backgroundColor: Colors.grey.shade400,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: onPressed,
            child: Text(btnText),
          ),
        ],
      );
    },
  );
}
