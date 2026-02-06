import 'package:flutter/material.dart';
import 'package:test_app/models/record.dart';

class RecordCard extends StatelessWidget {
  final RecordModel record;
  final bool isAdmin;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final Function(String) onStatusChange;

  const RecordCard({
    super.key,
    required this.record,
    required this.isAdmin,
    required this.onDelete,
    required this.onEdit,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
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

  Widget _buildDetailItem(IconData icon, String label, String value) {
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
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
      },
      itemBuilder: (context) => [
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
