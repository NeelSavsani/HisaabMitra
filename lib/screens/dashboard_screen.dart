import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hisaabmitra/config/database_config.dart';
import 'package:hisaabmitra/screens/add_expense.dart';
import 'package:hisaabmitra/screens/bottom_menu_bar.dart';
import 'package:hisaabmitra/screens/transaction_screen.dart';
import 'package:hisaabmitra/screens/transaction_detail_screen.dart';
import 'package:hisaabmitra/screens/transaction_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _openAddExpense(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AddExpenseScreen()),
    );
  }

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
          onPressed: () => _openAddExpense(context),
          tooltip: 'Add Expense',
          backgroundColor: const Color(0xFF8078F9),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 32),
        ),
      ),
      bottomNavigationBar: BottomMenuBar(
        selectedTab: BottomMenuTab.home,
        onHomeTap: () {},
        onTransactionsTap: () => Navigator.of(context).push(
          PageRouteBuilder<void>(
            pageBuilder: (_, __, ___) => const TransactionScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            transitionsBuilder: (_, __, ___, child) => child,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                    constraints: const BoxConstraints.tightFor(
                      width: 48,
                      height: 48,
                    ),
                    alignment: Alignment.center,
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.notifications_none_rounded),
                    color: const Color(0xFF494323),
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
                      Expanded(
                        flex: 2,
                        child: _QuickActionButton(
                          label: 'Add Expense',
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          icon: Icons.add,
                          backgroundColor: Color(0xFFFFDD32),
                          iconColor: Color(0xFF494323),
                          onTap: () => _openAddExpense(context),
                        ),
                      ),
                      SizedBox(width: 12,),
                      Expanded(
                        flex: 2,
                        child: _QuickActionButton(
                          label: 'Categories',
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          icon: Icons.category_rounded,
                          backgroundColor: const Color(0xFF8078F9).withValues(alpha: 0.3),
                          iconColor: const Color(0xFF8078F9),
                        ),
                      ),
                      SizedBox(width: 12,),
                      Expanded(
                        flex: 2,
                        child: _QuickActionButton(
                          label: 'Budgets',
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
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
                userId: user?.uid,
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class _RecentTransactionsSection extends StatelessWidget {
  const _RecentTransactionsSection({
    required this.transactions,
    required this.userId,
  });

  final DatabaseReference? transactions;
  final String? userId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: transactions?.onValue,
      builder: (context, snapshot) {
        final records = <Map<Object?, Object?>>[];
        final value = snapshot.data?.snapshot.value;
        if (value is Map) {
          for (final entry in value.entries) {
            final item = entry.value;
            if (item is Map && item['amount'] != null && item['type'] != null) {
              final record = Map<Object?, Object?>.from(item);
              record['id'] = entry.key.toString();
              records.add(record);
            }
          }
        }
        final colorOrder = [...records]
          ..sort((a, b) => a['id'].toString().compareTo(b['id'].toString()));
        if (colorOrder.isNotEmpty) {
          final randomStart =
              colorOrder.first['id'].toString().hashCode % 3;
          for (var index = 0; index < colorOrder.length; index++) {
            colorOrder[index]['colorIndex'] = (randomStart + index) % 3;
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
              ...records.take(4).map((record) {
                final type = record['type'].toString().toLowerCase();
                final amount = double.tryParse(record['amount'].toString()) ?? 0;
                final timestamp =
                    int.tryParse(record['createdAt']?.toString() ?? '') ?? 0;
                final title = record['title']?.toString().trim();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TransactionTile(
                    type: type,
                    amount: amount,
                    date: DateTime.fromMillisecondsSinceEpoch(timestamp),
                    title: title == null || title.isEmpty
                        ? 'Transaction'
                        : title,
                    paymentMode: record['paymentMode']?.toString() ?? '',
                    colorIndex: record['colorIndex'] as int? ?? 0,
                    onTap: () {
                      final id = record['id']?.toString();
                      final uid = userId;
                      if (id == null || uid == null || id.isEmpty) return;
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => TransactionDetailScreen(
                            userId: uid,
                            transactionId: id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

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
              fontSize: 24,
              fontWeight: FontWeight.w700,
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
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withValues(alpha: 0.8),
                  ),
                  amountStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MonthlyAmount(
                  label: 'This Month Expenses',
                  amount: expense,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withValues(alpha: 0.8),
                  ),
                  amountStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
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
  const _MonthlyAmount({required this.label, required this.amount, required TextStyle labelStyle, required TextStyle amountStyle});

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
                  const SizedBox(height: 24),
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
    required this.labelStyle,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final TextStyle labelStyle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Column(
        children: [
          Container(
            width: 96,
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
            style: labelStyle,
          ),
        ],
      ),
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
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ready to check your money?',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF494323),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
