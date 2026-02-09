import 'package:flutter/material.dart';
import 'package:test_app/models/record.dart';
import '../data/record_repository.dart';
import '../widgets/record_card.dart';
import '../widgets/dashboard_card.dart';

class ReportsTab extends StatefulWidget {
  final bool isAdmin;
  const ReportsTab({super.key, required this.isAdmin});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  final _repo = RecordRepository();
  List<RecordModel> _allRecords = [];
  List<RecordModel> _filteredRecords = [];
  bool _isLoading = true;

  final _challanCtrl = TextEditingController();
  final _poCtrl = TextEditingController();
  final _vendorCtrl = TextEditingController();
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final records = await _repo.fetchRecords();
    setState(() {
      _allRecords = records;
      _filteredRecords = records;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredRecords = _allRecords.where((r) {
        final matchChallan = r.challanNumber.contains(_challanCtrl.text.trim());
        final matchPo = (r.poNumber ?? '').contains(_poCtrl.text.trim());
        final matchVendor = (r.vendorName ?? '').toLowerCase().contains(_vendorCtrl.text.trim().toLowerCase());
        
        bool matchDate = true;
        if (_dateRange != null) {
          final recordDate = DateTime.parse(r.date ?? r.sentDate);
          matchDate = recordDate.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
                      recordDate.isBefore(_dateRange!.end.add(const Duration(days: 1)));
        }

        return matchChallan && matchPo && matchVendor && matchDate;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalQty = 0;
    int receivedQty = 0;
    for (var r in _filteredRecords) {
      totalQty += r.quantity;
      receivedQty += r.receivedQuantity;
    }
    int pendingQty = totalQty - receivedQty;

    return Column(
      children: [
        // Enhanced Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildFilterField(_challanCtrl, 'Challan', Icons.tag),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFilterField(_poCtrl, 'PO Number', Icons.assignment_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterField(_vendorCtrl, 'Vendor Name', Icons.person_outline),
                  ),
                  const SizedBox(width: 12),
                  _buildDateButton(),
                ],
              ),
            ],
          ),
        ),

        // Dynamic Dashboard Cards for Reports
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            children: [
              DashboardCard(
                title: 'Total Quantity',
                value: totalQty.toString(),
                subtitle: 'Items Sent',
                bgColor: const Color(0xFFE8EDFF),
                textColor: const Color(0xFF3F51B5),
              ),
              DashboardCard(
                title: 'Received Qty',
                value: receivedQty.toString(),
                subtitle: 'Items Returned',
                bgColor: const Color(0xFFE8F5E9),
                textColor: const Color(0xFF2E7D32),
              ),
              DashboardCard(
                title: 'Pending Qty',
                value: pendingQty.toString(),
                subtitle: 'To be Received',
                bgColor: const Color(0xFFFFEBEE),
                textColor: const Color(0xFFC62828),
              ),
            ],
          ),
        ),
        
        const Divider(height: 32),

        // Results Section
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredRecords.isEmpty
                  ? const Center(child: Text('No records found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _filteredRecords.length,
                      itemBuilder: (context, index) {
                        final r = _filteredRecords[index];
                        return RecordCard(
                          record: r,
                          isAdmin: widget.isAdmin,
                          onDelete: () async {
                            await _repo.deleteRecord(r.id);
                            _load();
                          },
                          onEdit: () {}, 
                          onReceive: (qty, date) async {
                             await _repo.receiveQuantity(
                               recordId: r.id,
                               newlyReceived: qty,
                               totalQuantity: r.quantity,
                               alreadyReceived: r.receivedQuantity,
                               receiveDate: date,
                             );
                             _load();
                          },
                          onStatusChange: (s) async {
                            await _repo.updateStatus(recordId: r.id, status: s);
                            _load();
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      onChanged: (_) => _applyFilters(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildDateButton() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: _dateRange == null ? Colors.grey.shade50 : Colors.indigo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _dateRange == null ? Colors.grey.shade400 : Colors.indigo),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => _dateRange = picked);
                _applyFilters();
              }
            },
            icon: Icon(Icons.date_range, color: _dateRange == null ? Colors.grey : Colors.indigo),
          ),
          if (_dateRange != null)
            IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.clear, size: 18, color: Colors.red),
              onPressed: () {
                setState(() => _dateRange = null);
                _applyFilters();
              },
            )
        ],
      ),
    );
  }
}
