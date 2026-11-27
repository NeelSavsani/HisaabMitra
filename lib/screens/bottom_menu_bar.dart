import 'package:flutter/material.dart';

enum BottomMenuTab { home, transactions, reports, profile }

class BottomMenuBar extends StatelessWidget {
  const BottomMenuBar({
    super.key,
    required this.selectedTab,
    this.onHomeTap,
    this.onTransactionsTap,
    this.onReportsTap,
    this.onProfileTap,
  });

  final BottomMenuTab selectedTab;
  final VoidCallback? onHomeTap;
  final VoidCallback? onTransactionsTap;
  final VoidCallback? onReportsTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: SizedBox(
        width: double.infinity,
        height: 84,
        child: CustomPaint(
          painter: const _NotchedBarPainter(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: _BottomMenuItem(
                    label: 'Home',
                    icon: Icons.grid_view_rounded,
                    selected: selectedTab == BottomMenuTab.home,
                    onTap: onHomeTap,
                  ),
                ),
                Expanded(
                  child: _BottomMenuItem(
                    label: 'Transactions',
                    icon: Icons.receipt_long_outlined,
                    selected: selectedTab == BottomMenuTab.transactions,
                    onTap: onTransactionsTap,
                  ),
                ),
                const SizedBox(
                  width: 96,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 28),
                      Text(
                        'Add Expense',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _BottomMenuItem(
                    label: 'Reports',
                    icon: Icons.analytics_outlined,
                    selected: selectedTab == BottomMenuTab.reports,
                    onTap: onReportsTap,
                  ),
                ),
                Expanded(
                  child: _BottomMenuItem(
                    label: 'Profile',
                    icon: Icons.account_circle_outlined,
                    selected: selectedTab == BottomMenuTab.profile,
                    onTap: onProfileTap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomMenuItem extends StatelessWidget {
  const _BottomMenuItem({
    required this.label,
    required this.icon,
    required this.selected,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF8078F9) : Colors.black54;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 25, color: color),
          const SizedBox(height: 3),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotchedBarPainter extends CustomPainter {
  const _NotchedBarPainter();

  static const double _cornerRadius = 16;
  static const double _notchHalfWidth = 78;
  static const double _notchDepth = 42;

  Path _buildPath(Size size) {
    final cx = size.width / 2;
    return Path()
      ..moveTo(0, _cornerRadius)
      ..quadraticBezierTo(0, 0, _cornerRadius, 0)
      ..lineTo(cx - _notchHalfWidth, 0)
      ..cubicTo(cx - 50, 0, cx - 42, _notchDepth, cx, _notchDepth)
      ..cubicTo(cx + 42, _notchDepth, cx + 50, 0, cx + _notchHalfWidth, 0)
      ..lineTo(size.width - _cornerRadius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, _cornerRadius)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);
    final shadowPaint = Paint()
      ..color = const Color(0xFFD5D3F5).withValues(alpha: 0.69)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
    canvas.drawPath(path.shift(const Offset(0, -2)), shadowPaint);
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _NotchedBarPainter oldDelegate) => false;
}
