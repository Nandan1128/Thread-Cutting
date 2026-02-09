import 'package:flutter/material.dart';
import 'package:test_app/models/record.dart';
import 'package:test_app/models/received_history.dart';
import 'package:test_app/data/record_repository.dart';

class RecordCard extends StatelessWidget {
  final RecordModel record;
  final bool isAdmin;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final Function(int, String) onReceive;
  final Function(String) onStatusChange;

  const RecordCard({
    super.key,
    required this.record,
    required this.isAdmin,
    required this.onDelete,
    required this.onEdit,
    required this.onReceive,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    int remaining = record.quantity - record.receivedQuantity;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatusIndicator(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Challan #${record.challanNumber}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                          _buildStatusBadge(context),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildDetailItem(Icons.inventory_2_outlined, 'Cloth', record.clothType),
                          const SizedBox(width: 24),
                          _buildDetailItem(Icons.numbers_outlined, 'Qty', '${record.quantity} pcs'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildDetailItem(Icons.person_outline, 'Vendor', record.vendorName ?? "Unknown"),
                          const SizedBox(width: 24),
                          if (record.poNumber != null && record.poNumber!.isNotEmpty)
                            _buildDetailItem(Icons.assignment_outlined, 'PO', record.poNumber!),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildDetailItem(
                            Icons.check_circle_outline, 
                            'Received', 
                            '${record.receivedQuantity} / ${record.quantity}',
                            valueColor: remaining > 0 ? Colors.orange : Colors.green,
                          ),
                          const SizedBox(width: 24),
                          if (remaining > 0)
                            _buildDetailItem(
                              Icons.pending_actions_outlined, 
                              'Remaining', 
                              '$remaining pcs',
                              valueColor: Colors.redAccent,
                            ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sent: ${record.sentDate}',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                              if (record.expectedReturnDate != null && record.expectedReturnDate!.isNotEmpty)
                                Text(
                                  'Due: ${record.expectedReturnDate}',
                                  style: TextStyle(
                                    fontSize: 11, 
                                    color: _isOverdue() ? Colors.red : Colors.grey.shade600,
                                    fontWeight: _isOverdue() ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              if (record.actualReturnDate != null && record.actualReturnDate!.isNotEmpty)
                                Text(
                                  'Last Received: ${record.actualReturnDate}',
                                  style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                          _buildActionMenu(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final status = record.status.toUpperCase();
    Color color = Colors.grey;
    if (status == 'SENT') color = Colors.orange;
    if (status == 'RETURNED' || status == 'COMPLETED') color = Colors.green;
    if (status == 'IN PROGRESS') color = Colors.blue;

    return Container(
      width: 6,
      color: color,
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, {Color? valueColor}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13, 
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final status = record.status.toUpperCase();
    Color color = Colors.grey;
    if (status == 'SENT') color = Colors.orange;
    if (status == 'RETURNED' || status == 'COMPLETED') color = Colors.green;
    if (status == 'IN PROGRESS') color = Colors.blue;

    return PopupMenuButton<String>(
      onSelected: onStatusChange,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      itemBuilder: (context) => [
        _buildPopupItem('Sent', Icons.outbox, Colors.orange),
        _buildPopupItem('In Progress', Icons.sync, Colors.blue),
        _buildPopupItem('Returned', Icons.check_circle_outline, Colors.green),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, Color color) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      icon: const Icon(Icons.more_horiz, color: Colors.indigo),
      onSelected: (val) {
        if (val == 'edit') onEdit();
        if (val == 'delete') onDelete();
        if (val == 'receive') _showReceiveDialog(context);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'receive',
          child: Row(
            children: [
              Icon(Icons.download_for_offline_outlined, size: 18, color: Colors.green),
              SizedBox(width: 12),
              Text('Receive Qty'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: Colors.indigo),
              SizedBox(width: 12),
              Text('Edit Record'),
            ],
          ),
        ),
        if (isAdmin)
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 18, color: Colors.red),
                SizedBox(width: 12),
                Text('Delete Record', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
      ],
    );
  }

  void _showReceiveDialog(BuildContext context) {
    final ctrl = TextEditingController();
    DateTime receiveDate = DateTime.now();
    int remaining = record.quantity - record.receivedQuantity;
    final repo = RecordRepository();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Receive Quantity'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Remaining Qty: $remaining', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter Newly Received Qty',
                    hintText: 'Max $remaining',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Receive Date: ${receiveDate.toLocal().toString().split(' ')[0]}"),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: receiveDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => receiveDate = picked);
                  },
                ),
                const Divider(height: 32),
                const Text('History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                FutureBuilder<List<ReceivedHistoryModel>>(
                  future: repo.fetchReceivedHistory(record.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No receiving history found', style: TextStyle(color: Colors.grey, fontSize: 12));
                    }
                    return Column(
                      children: snapshot.data!.map((h) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text('${h.quantity} pieces received'),
                        subtitle: Text('On ${h.receiveDate}'),
                        leading: const Icon(Icons.history, size: 16),
                      )).toList(),
                    );
                  },
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
                final newQty = int.tryParse(ctrl.text) ?? 0;
                if (newQty <= 0 || newQty > remaining) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid qty (Max $remaining)')),
                  );
                  return;
                }
                onReceive(newQty, receiveDate.toIso8601String().split('T')[0]);
                Navigator.pop(context);
              },
              child: const Text('Receive'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isOverdue() {
    if (record.status.toUpperCase() == 'RETURNED') return false;
    if (record.expectedReturnDate == null || record.expectedReturnDate!.isEmpty) return false;
    try {
      final dueDate = DateTime.parse(record.expectedReturnDate!);
      return dueDate.isBefore(DateTime.now()) && 
             dueDate.day != DateTime.now().day;
    } catch (_) {
      return false;
    }
  }
}
