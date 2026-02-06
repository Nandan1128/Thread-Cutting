import 'package:flutter/material.dart';
import '../models/record.dart';

Future<void> showEditRecordDialog({
  required BuildContext context,
  required RecordModel record,
  required Function(
    String challan,
    String cloth,
    int qty,
  ) onSave,
}) {
  final challanCtrl = TextEditingController(text: record.challanNumber);
  final clothCtrl = TextEditingController(text: record.clothType);
  final qtyCtrl = TextEditingController(text: record.quantity.toString());

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Record'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: challanCtrl,
              decoration: const InputDecoration(labelText: 'Challan Number'),
            ),
            TextField(
              controller: clothCtrl,
              decoration: const InputDecoration(labelText: 'Cloth Type'),
            ),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final qty = int.tryParse(qtyCtrl.text) ?? record.quantity;
            onSave(
              challanCtrl.text.trim(),
              clothCtrl.text.trim(),
              qty,
            );
            Navigator.pop(context);
          },
          child: const Text('Update'),
        ),
      ],
    ),
  );
}
