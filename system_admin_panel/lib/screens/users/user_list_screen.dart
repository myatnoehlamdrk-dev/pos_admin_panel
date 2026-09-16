import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';

import '../../widgets/confirm_dialog.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _searchController = TextEditingController();
  String? _selectedRole;
  bool? _selectedActive;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<UserProvider>().loadUsers(
          search: _searchController.text.isNotEmpty ? _searchController.text : null,
          role: _selectedRole,
          active: _selectedActive,
        );
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
                    'User Management',
                    style: GoogleFonts.inter(
                      fontSize: width > 600 ? 28 : 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${provider.total} users',
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
                          hintText: 'Search by name, email, phone...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _applyFilters(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 140,
                      child: DropdownButtonFormField<String>(
                        value: _selectedRole,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          DropdownMenuItem(value: 'manager', child: Text('Manager')),
                          DropdownMenuItem(value: 'cashier', child: Text('Cashier')),
                          DropdownMenuItem(value: 'staff', child: Text('Staff')),
                        ],
                        onChanged: (v) => setState(() => _selectedRole = v),
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
                      : provider.users.isEmpty
                          ? const Center(child: Text('No users found'))
                          : Column(
                              children: [
                                // Header
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
                                      Expanded(flex: 3, child: Text('User', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                      Expanded(flex: 2, child: Text('Role', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                      Expanded(flex: 2, child: Text('Shop', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                      Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                      SizedBox(width: 80, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                    ],
                                  ),
                                ),
                                // Rows
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: provider.users.length,
                                    itemBuilder: (context, index) {
                                      final user = provider.users[index];
                                      return _buildUserRow(context, user, provider, index);
                                    },
                                  ),
                                ),
                                // Pagination
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
                                              ? () => provider.loadUsers(page: provider.currentPage - 1)
                                              : null,
                                          icon: const Icon(Icons.chevron_left),
                                        ),
                                        Text('Page ${provider.currentPage} of ${provider.lastPage}'),
                                        IconButton(
                                          onPressed: provider.currentPage < provider.lastPage
                                              ? () => provider.loadUsers(page: provider.currentPage + 1)
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

  Widget _buildUserRow(BuildContext context, User user, UserProvider provider, int index) {
    return InkWell(
      onTap: () => _showUserDetail(context, user),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    child: Text(
                      user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                      style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13), overflow: TextOverflow.ellipsis),
                        Text(user.email, style: TextStyle(color: Colors.grey[500], fontSize: 12), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _roleColor(user.role).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  user.role ?? 'N/A',
                  style: TextStyle(color: _roleColor(user.role), fontSize: 12, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                user.shop?.shopName ?? 'Unassigned',
                style: TextStyle(color: user.shop != null ? const Color(0xFF1E293B) : Colors.grey[400], fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: user.activeStatus ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  user.activeStatus ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: user.activeStatus ? const Color(0xFF10B981) : Colors.red,
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
                    onPressed: () => _showToggleDialog(context, user, provider),
                    icon: Icon(
                      user.activeStatus ? Icons.block : Icons.check_circle,
                      color: user.activeStatus ? Colors.orange : Colors.green,
                      size: 20,
                    ),
                    tooltip: user.activeStatus ? 'Disable' : 'Enable',
                  ),
                  IconButton(
                    onPressed: () => _showDeleteDialog(context, user, provider),
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

  void _showUserDetail(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(user.email, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: user.activeStatus ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user.activeStatus ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: user.activeStatus ? const Color(0xFF10B981) : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 8),
                _detailRow(Icons.person_outline, 'Role', user.role ?? 'N/A'),
                _detailRow(Icons.store_outlined, 'Shop', user.shop?.shopName ?? 'Unassigned'),
                _detailRow(Icons.phone_outlined, 'Phone', user.phone ?? 'Not provided'),
                _detailRow(Icons.location_on_outlined, 'Address', user.address ?? 'Not provided'),
                _detailRow(Icons.credit_card_outlined, 'NRC No', user.nrcNo ?? 'Not provided'),
                _detailRow(Icons.wc_outlined, 'Gender', user.gender ?? 'Not provided'),
                _detailRow(Icons.cake_outlined, 'Date of Birth', user.dateOfBirth ?? 'Not provided'),
                _detailRow(Icons.payment_outlined, 'Billing Way', user.billingWay ?? 'Not provided'),
                _detailRow(Icons.verified_outlined, 'Verified', user.isVerified ? 'Yes' : 'No'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[500]),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Color _roleColor(String? role) {
    switch (role) {
      case 'admin':
        return const Color(0xFF8B5CF6);
      case 'manager':
        return const Color(0xFF3B82F6);
      case 'cashier':
        return const Color(0xFFF59E0B);
      case 'staff':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  Future<void> _showToggleDialog(BuildContext context, User user, UserProvider provider) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: user.activeStatus ? 'Disable User' : 'Enable User',
      content: 'Are you sure you want to ${user.activeStatus ? 'disable' : 'enable'} ${user.fullName}?',
      confirmText: user.activeStatus ? 'Disable' : 'Enable',
      confirmColor: user.activeStatus ? Colors.orange : Colors.green,
    );

    if (confirmed && context.mounted) {
      final success = await provider.toggleUserActive(user.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'User status updated' : 'Failed to update user'),
            backgroundColor: success ? const Color(0xFF10B981) : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, User user, UserProvider provider) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete User',
      content: 'Are you sure you want to delete ${user.fullName}? This action cannot be undone.',
      confirmText: 'Delete',
    );

    if (confirmed && context.mounted) {
      final success = await provider.deleteUser(user.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'User deleted' : 'Failed to delete user'),
            backgroundColor: success ? const Color(0xFF10B981) : Colors.red,
          ),
        );
      }
    }
  }
}
