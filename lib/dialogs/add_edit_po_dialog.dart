import 'package:flutter/material.dart';
import '../models/po.dart';

Future<void> showAddEditPODialog({
  required BuildContext context,
  POModel? po,
  required Function(POModel) onSave,
}) {
  final poCtrl = TextEditingController(text: po?.poNumber ?? '');
  final qtyCtrl = TextEditingController(text: po?.totalQuantity.toString() ?? '');

  final isEditing = po != null;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? 'Edit PO' : 'New PO Number',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12),
          TextField(
            controller: poCtrl,
            decoration: InputDecoration(
              labelText: 'PO Number',
              prefixIcon: const Icon(Icons.assignment_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: qtyCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Total Quantity',
              prefixIcon: const Icon(Icons.numbers),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (poCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter PO number')),
                  );
                  return;
                }
                final newPo = POModel(
                  id: po?.id ?? '',
                  poNumber: poCtrl.text.trim(),
                  totalQuantity: int.tryParse(qtyCtrl.text) ?? 0,
                  createdAt: po?.createdAt ?? DateTime.now().toIso8601String(),
                );
                onSave(newPo);
                Navigator.pop(context);
              },
              child: Text(
                isEditing ? 'UPDATE PO' : 'SAVE PO',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
