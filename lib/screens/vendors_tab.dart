import 'package:flutter/material.dart';
import 'package:test_app/models/vendor.dart';
import '../../data/vendor_repository.dart';
import '../../widgets/vendor_card.dart';
import '../../dialogs/add_edit_vendor_dialog.dart';

class VendorsTab extends StatefulWidget {
  final bool isAdmin;

  const VendorsTab({super.key, required this.isAdmin});

  @override
  State<VendorsTab> createState() => VendorsTabState();
}

class VendorsTabState extends State<VendorsTab> {
  final _repo = VendorRepository();
  late Future<List<VendorModel>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = _repo.fetchVendors();
    });
  }

  // Public refresh method
  void refresh() {
    _load();
  }

  Future<void> _delete(String id) async {
    await _repo.deleteVendor(id);
    _load();
  }

  Future<void> _edit(VendorModel vendor) async {
    await showAddEditVendorDialog(
      context: context,
      vendor: vendor,
      onSave: (updated) async {
        await _repo.updateVendor(updated);
        _load();
      },
    );
  }

  void showAddDialog() {
    showAddEditVendorDialog(
      context: context,
      onSave: (newVendor) async {
        await _repo.addVendor(newVendor);
        _load();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VendorModel>>(
      future: _future,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final vendors = snapshot.data!;
        if (vendors.isEmpty) {
          return const Center(child: Text('No vendors found'));
        }

        return ListView.builder(
          primary: false, // Fix for NestedScrollView assertion error
          padding: const EdgeInsets.all(12),
          itemCount: vendors.length,
          itemBuilder: (_, i) {
            final v = vendors[i];
            return VendorCard(
              vendor: v,
              isAdmin: widget.isAdmin,
              onDelete: () => _delete(v.id),
              onEdit: () => _edit(v),
            );
          },
        );
      },
    );
  }
}
