import 'package:flutter/material.dart';

addReminder(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const TextField(
              decoration: InputDecoration(hintText: 'Enter reminder'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
    },
  );
}
