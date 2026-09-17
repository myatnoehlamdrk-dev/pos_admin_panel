import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/user_detail_provider.dart';
import '../../utils/formatters.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<UserDetailProvider>();
      provider.loadUserDetail(widget.user.id);
      provider.loadUserAnalytics(widget.user.id);
      provider.loadUserTransactions(widget.user.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    context.read<UserDetailProvider>().reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.user.fullName,
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFF3B82F6),
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Analytics'),
            Tab(text: 'Transactions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(user: widget.user),
          _AnalyticsTab(userId: widget.user.id),
          _TransactionsTab(userId: widget.user.id),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final User user;

  const _OverviewTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailProvider>(
      builder: (context, provider, _) {
        final isLoading = provider.isLoadingDetail;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Color(0xFF3B82F6),
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _statusChip(user.activeStatus),
                              const SizedBox(width: 8),
                              _roleChip(user.role),
                              if (user.isVerified) ...[
                                const SizedBox(width: 8),
                                _verifiedChip(),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                _sectionTitle('Personal Information'),
                const SizedBox(height: 12),
                _infoGrid([
                  _infoItem(Icons.person_outline, 'Role', user.role ?? 'N/A'),
                  _infoItem(Icons.store_outlined, 'Shop', user.shop?.shopName ?? 'Unassigned'),
                  _infoItem(Icons.phone_outlined, 'Phone', user.phone ?? 'Not provided'),
                  _infoItem(Icons.location_on_outlined, 'Address', user.address ?? 'Not provided'),
                  _infoItem(Icons.credit_card_outlined, 'NRC No', user.nrcNo ?? 'Not provided'),
                  _infoItem(Icons.wc_outlined, 'Gender', user.gender ?? 'Not provided'),
                  _infoItem(Icons.cake_outlined, 'Date of Birth', user.dateOfBirth ?? 'Not provided'),
                  _infoItem(Icons.payment_outlined, 'Billing Way', user.billingWay ?? 'Not provided'),
                ]),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  final String userId;

  const _AnalyticsTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingAnalytics) {
          return const Center(child: CircularProgressIndicator());
        }

        final analytics = provider.analytics;
        if (analytics == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Analytics data will appear here',
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[500]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Waiting for backend endpoints...',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[400]),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Performance Summary'),
              const SizedBox(height: 12),
              _statsGrid([
                _statCard('Total Transactions', '${analytics.totalTransactions}', Icons.receipt_long, const Color(0xFF3B82F6)),
                _statCard('Avg Transaction', Formatters.currency(analytics.avgTransactionValue.toInt()), Icons.trending_up, const Color(0xFFF59E0B)),
                _statCard('Items Sold', '${analytics.totalItemsSold}', Icons.shopping_cart_outlined, const Color(0xFF8B5CF6)),
              ]),
              const SizedBox(height: 24),
              if (analytics.performance != null) ...[
                _sectionTitle('Performance Metrics'),
                const SizedBox(height: 12),
                _metricRow('Avg Daily Sales', Formatters.currency(analytics.performance!.avgDailySales.toInt())),
                _metricRow('Active Days', '${analytics.performance!.activeDays}'),
                _metricRow('Peak Hour', analytics.performance!.peakHour ?? 'N/A'),
                _metricRow('Completion Rate', '${(analytics.performance!.completionRate * 100).toStringAsFixed(1)}%'),
                const SizedBox(height: 24),
              ],
              if (analytics.topProducts.isNotEmpty) ...[
                _sectionTitle('Top Products'),
                const SizedBox(height: 12),
                ...analytics.topProducts.map((p) => _productTile(
                  p.productName,
                  p.shopName.isNotEmpty ? '${p.quantitySold} sold at ${p.shopName}' : '${p.quantitySold} sold',
                  Formatters.currency(p.totalRevenue),
                )),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TransactionsTab extends StatelessWidget {
  final String userId;

  const _TransactionsTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingTransactions) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No transactions yet',
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[500]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Transactions will appear here once available',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[400]),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    '${provider.transactionsTotal} transactions',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: provider.transactions.length,
                itemBuilder: (context, index) {
                  final tx = provider.transactions[index];
                  return _transactionTile(tx);
                },
              ),
            ),
            if (provider.transactionsLastPage > 1)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: provider.transactionsPage > 1
                          ? () => provider.loadUserTransactions(userId, page: provider.transactionsPage - 1)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text('Page ${provider.transactionsPage} of ${provider.transactionsLastPage}'),
                    IconButton(
                      onPressed: provider.transactionsPage < provider.transactionsLastPage
                          ? () => provider.loadUserTransactions(userId, page: provider.transactionsPage + 1)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

Widget _statusChip(bool isActive) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: isActive ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.red.shade50,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      isActive ? 'Active' : 'Inactive',
      style: TextStyle(
        color: isActive ? const Color(0xFF10B981) : Colors.red,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Widget _roleChip(String? role) {
  Color color;
  switch (role) {
    case 'admin':
      color = const Color(0xFF8B5CF6);
      break;
    case 'manager':
      color = const Color(0xFF3B82F6);
      break;
    case 'cashier':
      color = const Color(0xFFF59E0B);
      break;
    case 'staff':
      color = const Color(0xFF10B981);
      break;
    default:
      color = Colors.grey;
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      role ?? 'N/A',
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
}

Widget _verifiedChip() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: const Text(
      'Verified',
      style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
}

Widget _sectionTitle(String title) {
  return Text(
    title,
    style: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF1E293B),
    ),
  );
}

Widget _infoGrid(List<Widget> children) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Wrap(
      spacing: 16,
      runSpacing: 16,
      children: children,
    ),
  );
}

Widget _infoItem(IconData icon, String label, String value) {
  return SizedBox(
    width: 200,
    child: Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _statsGrid(List<Widget> children) {
  return Wrap(
    spacing: 16,
    runSpacing: 16,
    children: children,
  );
}

Widget _statCard(String label, String value, IconData icon, Color color) {
  return Container(
    width: 200,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500])),
      ],
    ),
  );
}

Widget _metricRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600])),
        Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
      ],
    ),
  );
}

Widget _productTile(String name, String subtitle, String revenue) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF3B82F6), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13), overflow: TextOverflow.ellipsis),
              Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
        ),
        Text(revenue, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    ),
  );
}

Widget _transactionTile(Map<String, dynamic> tx) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.receipt_long, color: Color(0xFF10B981), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tx['productName']?.toString() ?? tx['product_name']?.toString() ?? 'Sale',
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
              Text(
                Formatters.dateTime(tx['createdAt']?.toString() ?? tx['created_at']?.toString()),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              Formatters.currency(int.tryParse(tx['grandTotal']?.toString() ?? tx['grand_total']?.toString() ?? '0') ?? 0),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF10B981)),
            ),
            Text(
              tx['payMethod']?.toString() ?? tx['pay_method']?.toString() ?? '',
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
          ],
        ),
      ],
    ),
  );
}
