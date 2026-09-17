import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/shop_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/confirm_dialog.dart';
import 'shop_detail_screen.dart';

class ShopListScreen extends StatefulWidget {
  const ShopListScreen({super.key});

  @override
  State<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  final _searchController = TextEditingController();
  String? _selectedType;
  bool? _selectedActive;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProvider>().loadShops();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<ShopProvider>().loadShops(
          search: _searchController.text.isNotEmpty ? _searchController.text : null,
          type: _selectedType,
          active: _selectedActive,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopProvider>(
      builder: (context, provider, _) {
        final width = MediaQuery.of(context).size.width;
        final padding = width > 600 ? 24.0 : 16.0;

        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Shop Management',
                    style: GoogleFonts.inter(
                      fontSize: width > 600 ? 28 : 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${provider.total} shops',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Filters
              Container(
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
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search shops...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _applyFilters(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 140,
                      child: DropdownButtonFormField<bool>(
                        value: _selectedActive,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All')),
                          DropdownMenuItem(value: true, child: Text('Active')),
                          DropdownMenuItem(value: false, child: Text('Inactive')),
                        ],
                        onChanged: (v) => setState(() => _selectedActive = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Filter'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Table
              Expanded(
                child: Container(
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
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.shops.isEmpty
                          ? const Center(child: Text('No shops found'))
                          : Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Expanded(flex: 3, child: Text('Shop', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                      Expanded(flex: 2, child: Text('Owner', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                      Expanded(flex: 1, child: Text('Users', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                      Expanded(flex: 2, child: Text('Revenue', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                      Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                      SizedBox(width: 80, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: provider.shops.length,
                                    itemBuilder: (context, index) {
                                      final shop = provider.shops[index];
                                      return _buildShopRow(context, shop, provider);
                                    },
                                  ),
                                ),
                                if (provider.lastPage > 1)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: provider.currentPage > 1
                                              ? () => provider.loadShops(page: provider.currentPage - 1)
                                              : null,
                                          icon: const Icon(Icons.chevron_left),
                                        ),
                                        Text('Page ${provider.currentPage} of ${provider.lastPage}'),
                                        IconButton(
                                          onPressed: provider.currentPage < provider.lastPage
                                              ? () => provider.loadShops(page: provider.currentPage + 1)
                                              : null,
                                          icon: const Icon(Icons.chevron_right),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShopRow(BuildContext context, dynamic shop, ShopProvider provider) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ShopDetailScreen(shop: shop)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: shop.shopImage != null && shop.shopImage!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              shop.shopImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, error, stack) => const Icon(Icons.store, color: Color(0xFF3B82F6), size: 18),
                            ),
                          )
                        : const Icon(Icons.store, color: Color(0xFF3B82F6), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shop.shopName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13), overflow: TextOverflow.ellipsis),
                        Text(shop.shopType ?? '', style: TextStyle(color: Colors.grey[500], fontSize: 12), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(shop.ownerName ?? '-', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              flex: 1,
              child: Text('${shop.usersCount}', style: const TextStyle(fontSize: 13)),
            ),
            Expanded(
              flex: 2,
              child: Text(Formatters.currency(shop.totalRevenue ?? 0), style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: shop.isActive ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  shop.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: shop.isActive ? const Color(0xFF10B981) : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _showToggleDialog(context, shop, provider),
                    icon: Icon(
                      shop.isActive ? Icons.block : Icons.check_circle,
                      color: shop.isActive ? Colors.orange : Colors.green,
                      size: 20,
                    ),
                    tooltip: shop.isActive ? 'Deactivate' : 'Activate',
                  ),
                  IconButton(
                    onPressed: () => _showDeleteDialog(context, shop, provider),
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showToggleDialog(BuildContext context, dynamic shop, ShopProvider provider) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: shop.isActive ? 'Deactivate Shop' : 'Activate Shop',
      content: 'Are you sure you want to ${shop.isActive ? 'deactivate' : 'activate'} ${shop.shopName}?',
      confirmText: shop.isActive ? 'Deactivate' : 'Activate',
      confirmColor: shop.isActive ? Colors.orange : Colors.green,
    );

    if (confirmed && context.mounted) {
      final success = await provider.toggleShopActive(shop.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Shop status updated' : 'Failed to update shop'),
            backgroundColor: success ? const Color(0xFF10B981) : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, dynamic shop, ShopProvider provider) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Shop',
      content: 'Are you sure you want to delete ${shop.shopName}? This will unassign all users.',
      confirmText: 'Delete',
    );

    if (confirmed && context.mounted) {
      final success = await provider.deleteShop(shop.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Shop deleted' : 'Failed to delete shop'),
            backgroundColor: success ? const Color(0xFF10B981) : Colors.red,
          ),
        );
      }
    }
  }
}
