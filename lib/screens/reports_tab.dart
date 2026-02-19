import 'package:flutter/material.dart';
import 'package:test_app/models/record.dart';
import 'package:test_app/data/vendor_repository.dart';
import 'package:test_app/models/vendor.dart';
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
  final _vendorRepo = VendorRepository();
  List<RecordModel> _allRecords = [];
  List<RecordModel> _filteredRecords = [];
  List<VendorModel> _vendors = [];
  List<String> _pos = [];
  bool _isLoading = true;

  final _challanCtrl = TextEditingController();
  String? _selectedPoNumber;
  String? _selectedVendorName;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _repo.fetchRecords(),
      _vendorRepo.fetchVendors(),
    ]);
    setState(() {
      _allRecords = results[0] as List<RecordModel>;
      _filteredRecords = _allRecords;
      _vendors = results[1] as List<VendorModel>;
      
      // Extract unique PO numbers from records
      _pos = _allRecords
          .map((r) => r.poNumber ?? '')
          .where((po) => po.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
        
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredRecords = _allRecords.where((r) {
        final matchChallan = r.challanNumber.contains(_challanCtrl.text.trim());
        
        // Match selected PO number from dropdown
        final matchPo = _selectedPoNumber == null || 
            (r.poNumber ?? '') == _selectedPoNumber;
        
        // Match selected vendor name from dropdown
        final matchVendor = _selectedVendorName == null || 
            (r.vendorName ?? '').toLowerCase() == _selectedVendorName!.toLowerCase();

        bool matchDate = true;
        if (_dateRange != null) {
          final recordDate = DateTime.parse(r.date ?? r.sentDate);
          matchDate = recordDate
                  .isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
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
    double totalAmount = 0;

    for (var r in _filteredRecords) {
      totalQty += r.quantity;
      receivedQty += r.receivedQuantity;
      totalAmount += (r.receivedQuantity * (r.vendorRate ?? 0));
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
                  // PO Number Dropdown Filter
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPoNumber,
                      isDense: true,
                      decoration: InputDecoration(
                        labelText: 'Select PO',
                        prefixIcon: const Icon(Icons.assignment_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All POs')),
                        ..._pos.map((po) => DropdownMenuItem(
                          value: po,
                          child: Text(po, overflow: TextOverflow.ellipsis),
                        )).toList(),
                      ],
                      onChanged: (val) {
                        setState(() => _selectedPoNumber = val);
                        _applyFilters();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Vendor Name Dropdown Filter
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedVendorName,
                      isDense: true,
                      decoration: InputDecoration(
                        labelText: 'Select Vendor',
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Vendors')),
                        ..._vendors.map((v) => DropdownMenuItem(
                          value: v.name,
                          child: Text(v.name, overflow: TextOverflow.ellipsis),
                        )).toList(),
                      ],
                      onChanged: (val) {
                        setState(() => _selectedVendorName = val);
                        _applyFilters();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildDateButton(),
                ],
              ),
            ],
          ),
        ),

        // Dynamic Dashboard Cards
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            children: [
              DashboardCard(
                title: 'Total Amount',
                value: '₹${totalAmount.toStringAsFixed(2)}',
                subtitle: 'Based on Received',
                bgColor: const Color(0xFFFFF3E0),
                textColor: const Color(0xFFE65100),
                icon: Icons.payments_outlined,
              ),
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

  Widget _buildFilterField(
      TextEditingController ctrl, String label, IconData icon) {
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
        color: _dateRange == null
            ? Colors.grey.shade50
            : Colors.indigo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color:
                _dateRange == null ? Colors.grey.shade400 : Colors.indigo),
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
            icon: Icon(Icons.date_range,
                color: _dateRange == null ? Colors.grey : Colors.indigo),
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
