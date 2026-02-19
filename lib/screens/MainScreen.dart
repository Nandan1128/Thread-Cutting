import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_app/data/record_repository.dart';
import 'package:test_app/data/vendor_repository.dart';
import 'package:test_app/data/po_repository.dart';
import 'package:test_app/models/record.dart';
import 'package:test_app/models/po.dart';
import 'package:test_app/screens/login_screen.dart';
import 'package:test_app/screens/records_tab.dart';
import 'package:test_app/screens/vendors_tab.dart';
import 'package:test_app/screens/reports_tab.dart';
import '../widgets/dashboard_card.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../dialogs/add_edit_record_dialog.dart';
import '../dialogs/add_edit_vendor_dialog.dart';
import '../dialogs/add_edit_po_dialog.dart';

class MainScreen extends StatefulWidget {
  final bool isAdmin;

  const MainScreen({super.key, required this.isAdmin});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final GlobalKey<RecordsTabState> _recordsKey = GlobalKey<RecordsTabState>();
  final GlobalKey<VendorsTabState> _vendorsKey = GlobalKey<VendorsTabState>();
  
  final _recordRepo = RecordRepository();
  final _vendorRepo = VendorRepository();
  final _poRepo = PORepository();

  List<RecordModel> _allRecords = [];
  List<POModel> _allPos = [];
  bool _isLoading = true;
  String? _selectedPo;
  String _currentSearchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      final results = await Future.wait([
        _recordRepo.fetchRecords(),
        _poRepo.fetchPOs(),
      ]);
      if (mounted) {
        setState(() {
          _allRecords = results[0] as List<RecordModel>;
          _allPos = results[1] as List<POModel>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _refreshData() {
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _currentSearchQuery = query.toLowerCase();
    });
    if (_selectedPo != null) {
      _recordsKey.currentState?.onSearch(query);
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showAddRecordDialog() {
    showAddEditRecordDialog(
      context: context,
      onSave: (newRecord) async {
        await _recordRepo.addRecord(newRecord);
        _refreshData();
      },
    );
  }

  void _showAddVendorDialog() {
    showAddEditVendorDialog(
      context: context,
      onSave: (newVendor) async {
        await _vendorRepo.addVendor(newVendor);
        _refreshData();
      },
    );
  }

  void _showAddPODialog() {
    showAddEditPODialog(
      context: context,
      onSave: (newPo) async {
        await _poRepo.addPO(newPo);
        _refreshData();
      },
    );
  }

  Future<void> _deletePO(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete PO'),
        content: const Text('Are you sure you want to delete this PO?'),
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
      await _poRepo.deletePO(id);
      _refreshData();
    }
  }

  void _editPO(POModel po) {
    showAddEditPODialog(
      context: context,
      po: po,
      onSave: (updatedPo) async {
        await _poRepo.updatePO(updatedPo);
        _refreshData();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int total = _allRecords.length;
    int sent = _allRecords.where((r) => r.status.toLowerCase() == 'sent' || r.status.toLowerCase() == 'in progress').length;
    int received = _allRecords.where((r) => r.status.toLowerCase() == 'returned' || r.status.toLowerCase() == 'completed').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Threat Management',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            Text(
              'Track and manage cloth pieces',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _logout,
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 160,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          physics: const BouncingScrollPhysics(),
                          children: [
                            DashboardCard(
                              title: 'Total Record',
                              value: total.toString(),
                              subtitle: 'All entries',
                              bgColor: const Color(0xFFE8EDFF),
                              textColor: const Color(0xFF3F51B5),
                            ),
                            DashboardCard(
                              title: 'Sent',
                              value: sent.toString(),
                              subtitle: 'In process',
                              bgColor: const Color(0xFFFFF3E0),
                              textColor: const Color(0xFFE65100),
                            ),
                            DashboardCard(
                              title: 'Received',
                              value: received.toString(),
                              subtitle: 'Completed',
                              bgColor: const Color(0xFFE8F5E9),
                              textColor: const Color(0xFF2E7D32),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                                hintText: _selectedPo == null ? 'Search POs...' : 'Search records in PO...',
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Colors.indigo, width: 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.indigo,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.indigo,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: const [
                        Tab(text: 'PO Numbers'),
                        Tab(text: 'Vendors'),
                        Tab(text: 'Reports'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildPoListView(isDesktop),
                VendorsTab(key: _vendorsKey, isAdmin: widget.isAdmin),
                ReportsTab(isAdmin: widget.isAdmin),
              ],
            ),
          );
        }
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        activeBackgroundColor: Colors.redAccent,
        activeForegroundColor: Colors.white,
        visible: true,
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        elevation: 8.0,
        shape: const CircleBorder(),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.person_add_alt_1),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            label: 'Add Vendor',
            labelStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            onTap: _showAddVendorDialog,
          ),
          SpeedDialChild(
            child: const Icon(Icons.inventory_2),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            label: 'Add Record',
            labelStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            onTap: _showAddRecordDialog,
          ),
          SpeedDialChild(
            child: const Icon(Icons.assignment),
            backgroundColor: Colors.indigoAccent,
            foregroundColor: Colors.white,
            label: 'Add PO Number',
            labelStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            onTap: _showAddPODialog,
          ),
        ],
      ),
    );
  }

  Widget _buildPoListView(bool isDesktop) {
    if (_isLoading && _allPos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allPos.isEmpty) {
      return const Center(child: Text('No PO Numbers found. Add one using the + button.'));
    }

    final filteredPos = _allPos.where((po) => po.poNumber.toLowerCase().contains(_currentSearchQuery)).toList();

    if (_selectedPo != null) {
      return Column(
        children: [
          Container(
            color: Colors.white,
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.arrow_back, color: Colors.indigo),
              title: Text('PO: $_selectedPo', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 16)),
              subtitle: const Text('Back to PO List', style: TextStyle(fontSize: 11)),
              onTap: () {
                setState(() {
                  _selectedPo = null;
                  _searchController.clear();
                  _currentSearchQuery = "";
                });
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: RecordsTab(
              key: _recordsKey,
              isAdmin: widget.isAdmin,
              onDataChanged: _refreshData,
              poFilter: _selectedPo == 'N/A' ? '' : _selectedPo,
              records: _allRecords,
            ),
          ),
        ],
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(isDesktop ? 24 : 12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 6 : 2, // Responsive columns: 6 for desktop, 2 for mobile
        crossAxisSpacing: isDesktop ? 20 : 10,
        mainAxisSpacing: isDesktop ? 20 : 10,
        childAspectRatio: isDesktop ? 1.1 : 0.85, // Adjusted aspect ratio
      ),
      itemCount: filteredPos.length,
      itemBuilder: (context, index) {
        final po = filteredPos[index];
        final poRecords = _allRecords.where((r) => r.poNumber == po.poNumber);
        int sent = poRecords.fold(0, (sum, r) => sum + r.quantity);
        int received = poRecords.fold(0, (sum, r) => sum + r.receivedQuantity);
        int pending = po.totalQuantity - received;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedPo = po.poNumber;
              _searchController.clear();
              _currentSearchQuery = "";
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(isDesktop ? 16 : 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, color: Colors.indigo, size: isDesktop ? 32 : 24),
                      const SizedBox(height: 8),
                      Text(
                        po.poNumber, 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: isDesktop ? 14 : 13,
                          color: const Color(0xFF1A237E)
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Divider(height: 16),
                      _buildPoStatSmall('Total', po.totalQuantity.toString(), Colors.blue, isDesktop),
                      _buildPoStatSmall('Sent', sent.toString(), Colors.orange, isDesktop),
                      _buildPoStatSmall('Received', received.toString(), Colors.green, isDesktop),
                      _buildPoStatSmall('Pending', pending.toString(), Colors.redAccent, isDesktop),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: isDesktop ? 20 : 18, color: Colors.grey),
                    onSelected: (val) {
                      if (val == 'edit') _editPO(po);
                      if (val == 'delete') _deletePO(po.id);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit PO')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete PO', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPoStatSmall(String label, String value, Color color, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isDesktop ? 11 : 10, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: isDesktop ? 11 : 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF5F6FA),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: _tabBar,
      ),
    );
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
