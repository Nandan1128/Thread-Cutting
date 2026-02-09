import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_app/data/record_repository.dart';
import 'package:test_app/models/record.dart';
import 'package:test_app/screens/login_screen.dart';
import 'package:test_app/screens/records_tab.dart';
import 'package:test_app/screens/vendors_tab.dart';
import 'package:test_app/screens/reports_tab.dart';
import '../widgets/dashboard_card.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onFabPressed() {
    if (_tabController.index == 0) {
      _recordsKey.currentState?.showAddDialog();
    } else if (_tabController.index == 1) {
      _vendorsKey.currentState?.showAddDialog();
    }
  }

  void _onSearchChanged(String query) {
    if (_tabController.index == 0) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Threat Cutting Manager',
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  FutureBuilder<List<RecordModel>>(
                    future: _recordRepo.fetchRecords(),
                    builder: (context, snapshot) {
                      int total = 0;
                      int sent = 0;
                      int received = 0;

                      if (snapshot.hasData) {
                        final records = snapshot.data!;
                        total = records.length;
                        sent = records
                            .where((r) =>
                                r.status.toLowerCase() == 'sent' ||
                                r.status.toLowerCase() == 'in progress')
                            .length;
                        received = records
                            .where((r) =>
                                r.status.toLowerCase() == 'returned' ||
                                r.status.toLowerCase() == 'completed')
                            .length;
                      }

                      return SizedBox(
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
                      );
                    },
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.indigo),
                        hintText: 'Search records...',
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
                          borderSide:
                              const BorderSide(color: Colors.indigo, width: 1),
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
                    Tab(text: 'Records'),
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
            RecordsTab(key: _recordsKey, isAdmin: widget.isAdmin),
            VendorsTab(key: _vendorsKey, isAdmin: widget.isAdmin),
            ReportsTab(isAdmin: widget.isAdmin),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        elevation: 4,
        onPressed: _onFabPressed,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
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
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF5F6FA), // Match background
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
