import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/shop.dart';
import '../../providers/shop_detail_provider.dart';
import '../../utils/formatters.dart';

class ShopDetailScreen extends StatefulWidget {
  final Shop shop;

  const ShopDetailScreen({super.key, required this.shop});

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ShopDetailProvider>();
      provider.loadShopDetail(widget.shop.id);
      provider.loadShopAnalytics(widget.shop.id);
      provider.loadShopTransactions(widget.shop.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    context.read<ShopDetailProvider>().reset();
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
          widget.shop.shopName,
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
          _OverviewTab(shop: widget.shop),
          _AnalyticsTab(shopId: widget.shop.id),
          _TransactionsTab(shopId: widget.shop.id),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Shop shop;

  const _OverviewTab({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopDetailProvider>(
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
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: shop.shopImage != null && shop.shopImage!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                shop.shopImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, error, stack) =>
                                    const Icon(Icons.store, color: Color(0xFF3B82F6), size: 32),
                              ),
                            )
                          : const Icon(Icons.store, color: Color(0xFF3B82F6), size: 32),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop.shopName,
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            shop.shopType ?? 'Unknown type',
                            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          _statusChip(shop.isActive),
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
                _sectionTitle('Shop Information'),
                const SizedBox(height: 12),
                _infoGrid([
                  _infoItem(Icons.person_outline, 'Owner', shop.ownerName ?? 'Not provided'),
                  _infoItem(Icons.email_outlined, 'Owner Email', shop.ownerEmail ?? 'Not provided'),
                  _infoItem(Icons.phone_outlined, 'Owner Phone', shop.ownerPhone ?? 'Not provided'),
                  _infoItem(Icons.location_on_outlined, 'Address', shop.shopPhysicalAddress ?? 'Not provided'),
                  _infoItem(Icons.people_outlined, 'Users', '${shop.usersCount}'),
                  _infoItem(Icons.attach_money, 'Revenue', Formatters.currency(shop.totalRevenue ?? 0)),
                  _infoItem(Icons.calendar_today_outlined, 'Created', Formatters.date(shop.createdAt)),
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
  final String shopId;

  const _AnalyticsTab({required this.shopId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopDetailProvider>(
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
              _sectionTitle('Revenue Summary'),
              const SizedBox(height: 12),
              _statsGrid([
                _statCard('Total Sales', '${analytics.totalSales}', Icons.receipt_long, const Color(0xFF3B82F6)),
                _statCard('Total Revenue', Formatters.currency(analytics.totalRevenue), Icons.attach_money, const Color(0xFF10B981)),
                _statCard('Avg Sale', Formatters.currency(analytics.avgSaleValue.toInt()), Icons.trending_up, const Color(0xFFF59E0B)),
                _statCard('Products', '${analytics.totalProducts}', Icons.inventory_2_outlined, const Color(0xFF8B5CF6)),
              ]),
              const SizedBox(height: 24),
              if (analytics.performance != null) ...[
                _sectionTitle('Performance'),
                const SizedBox(height: 12),
                _metricRow('Avg Daily Revenue', Formatters.currency(analytics.performance!.avgDailyRevenue.toInt())),
                _metricRow('Active Days', '${analytics.performance!.activeDays}'),
                _metricRow('Growth Rate', '${(analytics.performance!.growthRate * 100).toStringAsFixed(1)}%'),
                _metricRow('Customer Retention', '${(analytics.performance!.customerRetention * 100).toStringAsFixed(1)}%'),
                const SizedBox(height: 24),
              ],
              if (analytics.salesByCategory.isNotEmpty) ...[
                _sectionTitle('Sales by Category'),
                const SizedBox(height: 12),
                ...analytics.salesByCategory.map((c) => _categoryTile(c.category, c.count, c.revenue)),
                const SizedBox(height: 24),
              ],
              if (analytics.topProducts.isNotEmpty) ...[
                _sectionTitle('Top Products'),
                const SizedBox(height: 12),
                ...analytics.topProducts.map((p) => _productTile(
                  p.productName,
                  '${p.quantitySold} sold',
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
  final String shopId;

  const _TransactionsTab({required this.shopId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopDetailProvider>(
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
                          ? () => provider.loadShopTransactions(shopId, page: provider.transactionsPage - 1)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text('Page ${provider.transactionsPage} of ${provider.transactionsLastPage}'),
                    IconButton(
                      onPressed: provider.transactionsPage < provider.transactionsLastPage
                          ? () => provider.loadShopTransactions(shopId, page: provider.transactionsPage + 1)
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

Widget _categoryTile(String category, int count, int revenue) {
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
          child: const Icon(Icons.category_outlined, color: Color(0xFF3B82F6), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              Text('$count items', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
        ),
        Text(Formatters.currency(revenue), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF10B981), size: 18),
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
