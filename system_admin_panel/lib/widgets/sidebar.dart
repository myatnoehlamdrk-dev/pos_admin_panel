import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;
  final bool isCollapsed;
  final Function(bool) onToggleCollapse;

  const Sidebar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.isCollapsed,
    required this.onToggleCollapse,
  });

  static const _labels = [
    'Dashboard',
    'Staff Approval',
    'Users',
    'Shops',
  ];

  static const _icons = [
    Icons.dashboard_outlined,
    Icons.how_to_reg_outlined,
    Icons.people_outline,
    Icons.store_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isCollapsed ? 60 : 240,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 64,
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 6 : 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 18),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const Spacer(),
                InkWell(
                  onTap: () => onToggleCollapse(!isCollapsed),
                  child: Icon(
                    isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                    color: Colors.white54,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 8),
          ...List.generate(_labels.length, (index) {
            final isSelected = currentIndex == index;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onIndexChanged(index),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF3B82F6).withValues(alpha: 0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _icons[index],
                          color: isSelected ? const Color(0xFF3B82F6) : Colors.white54,
                          size: 22,
                        ),
                        if (!isCollapsed) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _labels[index],
                              style: TextStyle(
                                color: isSelected ? const Color(0xFF3B82F6) : Colors.white70,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showLogoutDialog(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.logout, color: Colors.white54, size: 22),
                      if (!isCollapsed) ...[
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Logout',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
