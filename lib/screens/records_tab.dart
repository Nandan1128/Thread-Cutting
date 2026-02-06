import 'package:flutter/material.dart';
import 'package:test_app/models/record.dart';
import '../../data/record_repository.dart';
import '../../widgets/record_card.dart';
import '../../dialogs/add_edit_record_dialog.dart';

class RecordsTab extends StatefulWidget {
  final bool isAdmin;

  const RecordsTab({super.key, required this.isAdmin});

  @override
  State<RecordsTab> createState() => RecordsTabState();
}

class RecordsTabState extends State<RecordsTab> {
  final _repo = RecordRepository();
  List<RecordModel> _allRecords = [];
  List<RecordModel> _filteredRecords = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() => _isLoading = true);
      final records = await _repo.fetchRecords();
      setState(() {
        _allRecords = records;
        _filteredRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRecords = _allRecords;
      } else {
        final q = query.toLowerCase();
        _filteredRecords = _allRecords.where((r) {
          final challan = r.challanNumber.toLowerCase();
          final po = (r.poNumber ?? '').toLowerCase();
          final vendor = (r.vendorName ?? '').toLowerCase();
          return challan.contains(q) || po.contains(q) || vendor.contains(q);
        }).toList();
      }
    });
  }

  Future<void> _delete(String id) async {
    await _repo.deleteRecord(id);
    _load();
  }

  Future<void> _edit(RecordModel record) async {
    await showAddEditRecordDialog(
      context: context,
      record: record,
      onSave: (updated) async {
        await _repo.updateRecord(updated);
        _load();
      },
    );
  }

  void showAddDialog() {
    showAddEditRecordDialog(
      context: context,
      onSave: (newRecord) async {
        await _repo.addRecord(newRecord);
        _load();
      },
    );
  }

  Future<void> _updateStatus(String id, String status) async {
    await _repo.updateStatus(
      recordId: id,
      status: status,
      actualReturnDate:
          status == 'Returned' ? DateTime.now().toIso8601String() : null,
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

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
          onStatusChange: (s) => _updateStatus(r.id, s),
        );
      },
    );
  }
}
