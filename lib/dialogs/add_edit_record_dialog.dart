import 'package:flutter/material.dart';
import 'package:test_app/data/vendor_repository.dart';
import 'package:test_app/data/po_repository.dart';
import '../models/record.dart';
import '../models/po.dart';

Future<void> showAddEditRecordDialog({
  required BuildContext context,
  RecordModel? record,
  required Function(RecordModel) onSave,
}) async {
  final isEditing = record != null;

  final challanCtrl = TextEditingController(text: record?.challanNumber ?? '');
  final clothCtrl = TextEditingController(text: record?.clothType ?? '');
  final qtyCtrl = TextEditingController(text: record?.quantity.toString() ?? '');
  final notesCtrl = TextEditingController(text: record?.notes ?? '');

  String? selectedVendorId = record?.vendorId;
  String? selectedPoNumber = record?.poNumber;
  String selectedStatus = record?.status ?? 'Sent';
  
  DateTime sentDate =
      record != null ? DateTime.parse(record.sentDate) : DateTime.now();

  DateTime? expectedDate;
  if (record?.expectedReturnDate != null &&
      record!.expectedReturnDate!.isNotEmpty) {
    expectedDate = DateTime.parse(record.expectedReturnDate!);
  }

  // Load vendors and POs
  final vendors = await VendorRepository().fetchVendors();
  final pos = await PORepository().fetchPOs();

  if (!context.mounted) return;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Container(
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Record' : 'New Entry',
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
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: challanCtrl,
                      label: 'Challan Number',
                      icon: Icons.tag,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedPoNumber,
                      decoration: InputDecoration(
                        labelText: 'Select PO',
                        prefixIcon: const Icon(Icons.assignment_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: pos.map((p) => DropdownMenuItem(
                        value: p.poNumber,
                        child: Text(p.poNumber),
                      )).toList(),
                      onChanged: (val) => setState(() => selectedPoNumber = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: clothCtrl,
                label: 'Cloth Type',
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: qtyCtrl,
                label: 'Quantity',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedVendorId,
                decoration: InputDecoration(
                  labelText: 'Select Vendor',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: vendors
                    .map((v) => DropdownMenuItem(
                          value: v.id,
                          child: Text(v.name),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => selectedVendorId = val),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      context: context,
                      label: 'Sent Date',
                      date: sentDate,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: sentDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => sentDate = picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDatePicker(
                      context: context,
                      label: 'Due Date',
                      date: expectedDate,
                      isOptional: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: expectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => expectedDate = picked);
                      },
                      onClear: () => setState(() => expectedDate = null),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: notesCtrl,
                label: 'Notes (Optional)',
                icon: Icons.note_alt_outlined,
                maxLines: 2,
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
                    if (selectedVendorId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a vendor')),
                      );
                      return;
                    }
                    if (selectedPoNumber == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a PO Number')),
                      );
                      return;
                    }
                    final newRecord = RecordModel(
                      id: record?.id ?? '',
                      date: record?.date ??
                          DateTime.now().toIso8601String().split('T')[0],
                      challanNumber: challanCtrl.text.trim(),
                      poNumber: selectedPoNumber,
                      clothType: clothCtrl.text.trim(),
                      quantity: int.tryParse(qtyCtrl.text) ?? 0,
                      vendorId: selectedVendorId!,
                      status: selectedStatus,
                      sentDate: sentDate.toIso8601String().split('T')[0],
                      expectedReturnDate:
                          expectedDate?.toIso8601String().split('T')[0],
                      notes: notesCtrl.text.trim().isEmpty
                          ? null
                          : notesCtrl.text.trim(),
                    );
                    onSave(newRecord);
                    Navigator.pop(context);
                  },
                  child: Text(
                    isEditing ? 'UPDATE RECORD' : 'SAVE ENTRY',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}

Widget _buildDatePicker({
  required BuildContext context,
  required String label,
  required DateTime? date,
  required VoidCallback onTap,
  VoidCallback? onClear,
  bool isOptional = false,
}) {
  return InkWell(
    onTap: onTap,
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today, size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
        suffixIcon: isOptional && date != null
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: onClear,
              )
            : null,
      ),
      child: Text(
        date != null ? date.toLocal().toString().split(' ')[0] : 'Optional',
        style: TextStyle(fontSize: 14, color: date == null ? Colors.grey : Colors.black),
      ),
    ),
  );
}
