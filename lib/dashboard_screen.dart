import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

import 'database_config.dart';
import 'welcome_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final profile = user == null
        ? null
        : FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: realtimeDatabaseUrl,
    ).ref('users/${user.uid}');

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF3),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 72,
        height: 72,
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          onPressed: () {},
          tooltip: 'Add Expense',
          backgroundColor: const Color(0xFF8078F9),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 32),
        ),
      ),
      bottomNavigationBar: SafeArea(
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
                children: const [
                  Expanded(
                    child: _BottomMenuItem(
                      label: 'Home',
                      icon: Icons.grid_view_rounded,
                      selected: true,
                    ),
                  ),
                  Expanded(
                    child: _BottomMenuItem(
                      label: 'Expenses',
                      icon: Icons.receipt_long_outlined,
                    ),
                  ),
                  SizedBox(
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
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _BottomMenuItem(
                      label: 'Reports',
                      icon: Icons.analytics_outlined,
                    ),
                  ),
                  Expanded(
                    child: _BottomMenuItem(
                      label: 'Profile',
                      icon: Icons.account_circle_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/common_logo.png',
                    width: 120,
                    height: 48,
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    tooltip: 'Notifications',
                    icon: const Icon(Icons.notifications_none_rounded),
                    color: const Color(0xFF494323),
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton<_ProfileMenuAction>(
                    tooltip: 'Profile menu',
                    onSelected: (action) async {
                      switch (action) {
                        case _ProfileMenuAction.yourProfile:
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Your Profile is coming soon.'),
                            ),
                          );
                          break;
                        case _ProfileMenuAction.logout:
                          await FirebaseAuth.instance.signOut();
                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const WelcomeScreen(),
                            ),
                                (_) => false,
                          );
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _ProfileMenuAction.yourProfile,
                        child: Text('Your Profile'),
                      ),
                      PopupMenuItem(
                        value: _ProfileMenuAction.logout,
                        child: Text('Logout'),
                      ),
                    ],
                    child: const CircleAvatar(
                      radius: 19,
                      backgroundColor: Color(0xFFE8E3D4),
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: Color(0xFF494323),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: profile == null
                    ? const _WelcomeText(username: 'there')
                    : StreamBuilder<DatabaseEvent>(
                  stream: profile.onValue,
                  builder: (context, snapshot) {
                    final data = snapshot.data?.snapshot.value;
                    final username = data is Map
                        ? data['name']?.toString()
                        : null;
                    return _WelcomeText(
                      username:
                      username == null || username.trim().isEmpty
                          ? user?.displayName ?? 'there'
                          : username,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: StreamBuilder<DatabaseEvent>(
                stream: profile?.child('transactions').onValue,
                builder: (context, snapshot) {
                  final totals = _monthlyTotals(snapshot.data?.snapshot.value);
                  return _MonthlyBalanceCard(
                    income: totals.income,
                    expense: totals.expense,
                  );
                },
              ),
            ),
            // Quick actions for the dashboard's main money-management tasks.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Action',
                    style: GoogleFonts.chewy(fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(
                        child: _QuickActionButton(
                          label: 'Add Expense',
                          icon: Icons.add,
                          backgroundColor: Color(0xFFFFDD32),
                          iconColor: Color(0xFF494323),
                        ),
                      ),
                      Expanded(
                        child: _QuickActionButton(
                          label: 'Categories',
                          icon: Icons.category_rounded,
                          backgroundColor: const Color(0xFF8078F9).withValues(alpha: 0.3),
                          iconColor: const Color(0xFF8078F9),
                        ),
                      ),
                      Expanded(
                        child: _QuickActionButton(
                          label: 'Budgets',
                          icon: Icons.account_balance_wallet_rounded,
                          backgroundColor: const Color(0xFFF6BA11).withValues(alpha: 0.5),
                          iconColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Monthly budget summary with progress and remaining amount.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: _MonthlyBudgetCard(profile: profile),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: _RecentTransactionsSection(
                transactions: profile?.child('transactions'),
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}

/// Paints the bottom bar with a smooth, wide curved notch in the center
/// (like the reference design) instead of a circular notch.
class _NotchedBarPainter extends CustomPainter {
  const _NotchedBarPainter();

  static const double _cornerRadius = 16;
  static const double _notchHalfWidth = 78;
  static const double _notchDepth = 42;

  Path _buildPath(Size size) {
    final cx = size.width / 2;
    final path = Path()
      ..moveTo(0, _cornerRadius)
      ..quadraticBezierTo(0, 0, _cornerRadius, 0)
      ..lineTo(cx - _notchHalfWidth, 0)
    // Smooth curve going down into the notch.
      ..cubicTo(
        cx - 50,
        0,
        cx - 42,
        _notchDepth,
        cx,
        _notchDepth,
      )
    // Smooth curve coming back up out of the notch.
      ..cubicTo(
        cx + 42,
        _notchDepth,
        cx + 50,
        0,
        cx + _notchHalfWidth,
        0,
      )
      ..lineTo(size.width - _cornerRadius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, _cornerRadius)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);

    // Box shadow: x: 0, y: -2, blur: 2, spread: 0, color: D5D3F5, opacity: 69%.
    // (Flutter's blur sigma = CSS/Figma blur / 2.)
    final shadowPaint = Paint()
      ..color = const Color(0xFFD5D3F5).withValues(alpha: 0.69)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
    canvas.drawPath(path.shift(const Offset(0, -2)), shadowPaint);

    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RecentTransactionsSection extends StatelessWidget {
  const _RecentTransactionsSection({required this.transactions});

  final DatabaseReference? transactions;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: transactions?.onValue,
      builder: (context, snapshot) {
        final records = <Map>[];
        final value = snapshot.data?.snapshot.value;
        if (value is Map) {
          for (final item in value.values) {
            if (item is Map && item['amount'] != null && item['type'] != null) {
              records.add(Map<Object?, Object?>.from(item));
            }
          }
        }
        records.sort((a, b) {
          final dateA = int.tryParse(a['createdAt']?.toString() ?? '') ?? 0;
          final dateB = int.tryParse(b['createdAt']?.toString() ?? '') ?? 0;
          return dateB.compareTo(dateA);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transaction',
                  style: GoogleFonts.chewy(fontSize: 20),
                ),
                Row(
                  children: const [
                    Text(
                      'See All',
                      style: TextStyle(color: Color(0xFF8078F9), fontSize: 15),
                    ),
                    Icon(Icons.chevron_right, color: Color(0xFF8078F9)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (records.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, color: Color(0xFF8078F9), size: 20),
                    SizedBox(width: 8),
                    Text('No recent transactions'),
                  ],
                ),
              )
            else
              ...records.take(3).map((record) {
                final type = record['type'].toString();
                final isIncome = type.toLowerCase() == 'income';
                final amount =
                    double.tryParse(record['amount'].toString()) ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isIncome
                            ? const Color(0xFFE7F5E8)
                            : const Color(0xFFFFE7E7),
                        child: Icon(
                          isIncome
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: isIncome ? Colors.green : Colors.redAccent,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          type.isEmpty
                              ? 'Transaction'
                              : '${type[0].toUpperCase()}${type.substring(1)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        '${isIncome ? '+' : '-'}${_formatRupees(amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isIncome ? Colors.green : Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

class _BottomMenuItem extends StatelessWidget {
  const _BottomMenuItem({
    required this.label,
    required this.icon,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF8078F9) : Colors.black54;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 25, color: color),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

enum _ProfileMenuAction { yourProfile, logout }

({double income, double expense}) _monthlyTotals(Object? value) {
  var income = 0.0;
  var expense = 0.0;
  final now = DateTime.now();

  if (value is Map) {
    for (final entry in value.values) {
      if (entry is! Map) continue;

      final amount = double.tryParse(entry['amount']?.toString() ?? '');
      final timestamp = int.tryParse(entry['createdAt']?.toString() ?? '');
      final type = entry['type']?.toString().toLowerCase();
      if (amount == null || timestamp == null) continue;

      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (date.year != now.year || date.month != now.month) continue;

      if (type == 'income') income += amount;
      if (type == 'expense') expense += amount;
    }
  }

  return (income: income, expense: expense);
}

class _MonthlyBalanceCard extends StatelessWidget {
  const _MonthlyBalanceCard({required this.income, required this.expense});

  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDD32),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOTAL RECORDED BALANCE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF29250E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatRupees(income - expense),
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MonthlyAmount(
                  label: 'This Month Income',
                  amount: income,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MonthlyAmount(
                  label: 'This Month Expenses',
                  amount: expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthlyAmount extends StatelessWidget {
  const _MonthlyAmount({required this.label, required this.amount});

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1A1),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            _formatRupees(amount),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _MonthlyBudgetCard extends StatelessWidget {
  const _MonthlyBudgetCard({required this.profile});

  final DatabaseReference? profile;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: profile?.child('monthlyBudget').onValue,
      builder: (context, budgetSnapshot) {
        final budgetData = budgetSnapshot.data?.snapshot.value;
        final budgetValue = budgetData is Map
            ? budgetData['amount']
            : budgetData;
        final budget = double.tryParse(budgetValue?.toString() ?? '') ?? 0;

        return StreamBuilder<DatabaseEvent>(
          stream: profile?.child('transactions').onValue,
          builder: (context, transactionSnapshot) {
            final totals = _monthlyTotals(
              transactionSnapshot.data?.snapshot.value,
            );
            final spent = totals.expense;
            final percentage = budget > 0 ? spent / budget : 0.0;
            final progress = percentage.clamp(0.0, 1.0).toDouble();
            final remaining = (budget - spent).clamp(0.0, double.infinity);

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    color: const Color(0xFFE7E3D3).withValues(alpha: 0.5),
                    width: 2
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Monthly Budget',
                        style: GoogleFonts.chewy(fontSize: 20),
                      ),
                      Text(
                        '${(percentage * 100).round()}%',
                        style: GoogleFonts.chewy(fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 18,
                      color: const Color(0xFFEEEEEE),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFFDD32),
                                Color(0xFF8078F9),
                              ],
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_formatRupees(spent)} spent'),
                      Text('${_formatRupees(remaining)} remaining'),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10, color: Colors.black),
        ),
      ],
    );
  }
}

String _formatRupees(double amount) {
  final fixed = amount.toStringAsFixed(2).split('.');
  final digits = fixed[0].replaceFirst('-', '');
  var grouped = digits;
  if (digits.length > 3) {
    final lastThree = digits.substring(digits.length - 3);
    var leading = digits.substring(0, digits.length - 3);
    leading = leading.replaceAllMapped(
      RegExp(r'\B(?=(\d{2})+(?!\d))'),
          (_) => ',',
    );
    grouped = '$leading,$lastThree';
  }
  final sign = amount < 0 ? '-' : '';
  return '$sign₹ $grouped.${fixed[1]}';
}

class _WelcomeText extends StatelessWidget {
  const _WelcomeText({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final trimmedName = username.trim();
    final firstName = trimmedName.isEmpty
        ? 'there'
        : trimmedName.split(RegExp(r'\s+')).first;
    final greeting = switch (hour) {
      >= 5 && < 12 => 'Good morning',
      >= 12 && < 17 => 'Good afternoon',
      >= 17 && < 21 => 'Good evening',
      _ => 'Good night',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$greeting, $firstName!',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ready to check your money?',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF494323),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
