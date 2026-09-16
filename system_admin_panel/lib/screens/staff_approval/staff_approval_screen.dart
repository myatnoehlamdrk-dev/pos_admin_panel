import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/shop.dart';
import '../../providers/user_provider.dart';
import '../../repositories/admin_repository.dart';
import '../../utils/formatters.dart';


class StaffApprovalScreen extends StatefulWidget {
  const StaffApprovalScreen({super.key});

  @override
  State<StaffApprovalScreen> createState() => _StaffApprovalScreenState();
}

class _StaffApprovalScreenState extends State<StaffApprovalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadPendingUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
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
                    'Staff Approval',
                    style: GoogleFonts.inter(
                      fontSize: width > 600 ? 28 : 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${provider.pendingUsers.length} pending',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (provider.isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (provider.pendingUsers.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: Colors.green[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No pending approvals',
                          style: GoogleFonts.inter(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.pendingUsers.length,
                    itemBuilder: (context, index) {
                      final user = provider.pendingUsers[index];
                      return _buildUserCard(context, user, provider);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserCard(BuildContext context, dynamic user, UserProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
            child: Text(
              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
              style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  '${user.role ?? "N/A"} • Registered ${Formatters.date(user.dateOfBirth)}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _showApproveDialog(context, user.id, provider),
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showApproveDialog(BuildContext context, String userId, UserProvider provider) async {
    Shop? selectedShop;
    List<Shop> shops = [];

    try {
      final adminRepo = context.read<AdminRepository>();
      final result = await adminRepo.getShops(perPage: 100);
      shops = result.items;
    } catch (_) {}

    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Approve User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select a shop to assign:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<Shop>(
                value: selectedShop,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Shop',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: shops.map((shop) {
                  return DropdownMenuItem(
                    value: shop,
                    child: Text(shop.shopName),
                  );
                }).toList(),
                onChanged: (shop) => setDialogState(() => selectedShop = shop),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: selectedShop == null
                  ? null
                  : () => Navigator.pop(ctx, true),
              child: const Text('Approve', style: TextStyle(color: Color(0xFF10B981))),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && selectedShop != null && context.mounted) {
      final success = await provider.approveUser(userId, selectedShop!.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'User approved successfully' : 'Failed to approve user'),
            backgroundColor: success ? const Color(0xFF10B981) : Colors.red,
          ),
        );
      }
    }
  }
}
