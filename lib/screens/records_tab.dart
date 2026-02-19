import 'package:flutter/material.dart';
import 'package:test_app/models/record.dart';
import '../../data/record_repository.dart';
import '../../widgets/record_card.dart';
import '../../dialogs/add_edit_record_dialog.dart';

class RecordsTab extends StatefulWidget {
  final bool isAdmin;
  final VoidCallback? onDataChanged;
  final String? poFilter;
  final List<RecordModel> records; // Required records from parent

  const RecordsTab({
    super.key,
    required this.isAdmin,
    this.onDataChanged,
    this.poFilter,
    required this.records,
  });

  @override
  State<RecordsTab> createState() => RecordsTabState();
}

class RecordsTabState extends State<RecordsTab> {
  final _repo = RecordRepository();
  List<RecordModel> _filteredRecords = [];

  @override
  void initState() {
    super.initState();
    _applyLocalFilters();
  }

  @override
  void didUpdateWidget(covariant RecordsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.records != widget.records || oldWidget.poFilter != widget.poFilter) {
      _applyLocalFilters();
    }
  }

  // Public search method used by MainScreen
  void onSearch(String query) {
    setState(() {
      final baseList = widget.poFilter != null 
          ? widget.records.where((r) => (r.poNumber ?? '') == widget.poFilter)
          : widget.records;

      if (query.isEmpty) {
        _filteredRecords = baseList.toList();
      } else {
        final q = query.toLowerCase();
        _filteredRecords = baseList.where((r) {
          final challan = r.challanNumber.toLowerCase();
          final po = (r.poNumber ?? '').toLowerCase();
          final vendor = (r.vendorName ?? '').toLowerCase();
          return challan.contains(q) || po.contains(q) || vendor.contains(q);
        }).toList();
      }
    });
  }

  void _applyLocalFilters() {
    setState(() {
      if (widget.poFilter != null) {
        _filteredRecords = widget.records.where((r) => (r.poNumber ?? '') == widget.poFilter).toList();
      } else {
        _filteredRecords = widget.records;
      }
    });
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repo.deleteRecord(id);
      widget.onDataChanged?.call(); // Refresh parent
    }
  }

  Future<void> _edit(RecordModel record) async {
    await showAddEditRecordDialog(
      context: context,
      record: record,
      onSave: (updated) async {
        await _repo.updateRecord(updated);
        widget.onDataChanged?.call(); // Refresh parent
      },
    );
  }

  Future<void> _onReceive(RecordModel r, int newlyReceived, String date) async {
    await _repo.receiveQuantity(
      recordId: r.id,
      newlyReceived: newlyReceived,
      totalQuantity: r.quantity,
      alreadyReceived: r.receivedQuantity,
      receiveDate: date,
    );
    widget.onDataChanged?.call(); // Refresh parent
  }

  Future<void> _updateStatus(String id, String status) async {
    await _repo.updateStatus(
      recordId: id,
      status: status,
      actualReturnDate: status == 'Returned' ? DateTime.now().toIso8601String() : null,
    );
    widget.onDataChanged?.call(); // Refresh parent
  }

  @override
  Widget build(BuildContext context) {
    if (_filteredRecords.isEmpty) {
      return const Center(child: Text('No records found'));
    }

    return ListView.builder(
      primary: false,
      padding: const EdgeInsets.all(12),
      itemCount: _filteredRecords.length,
      itemBuilder: (_, i) {
        final r = _filteredRecords[i];
        return RecordCard(
          record: r,
          isAdmin: widget.isAdmin,
          onEdit: () => _edit(r),
          onDelete: () => _delete(r.id),
          onReceive: (qty, date) => _onReceive(r, qty, date),
          onStatusChange: (s) => _updateStatus(r.id, s),
        );
      },
    );
  }
}
