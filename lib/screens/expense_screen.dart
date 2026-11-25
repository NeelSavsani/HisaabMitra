import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hisaabmitra/config/database_config.dart';
import 'package:hisaabmitra/screens/add_expense.dart';
import 'package:hisaabmitra/screens/transaction_tile.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final Map<_ExpenseFilterType, int> _selectedFilters = {};
  final List<_ExpenseFilterType> _filterOrder = [];
  String _searchQuery = '';

  static const List<_ExpenseFilterType> _defaultFilterOrder = [
    _ExpenseFilterType.date,
    _ExpenseFilterType.status,
    _ExpenseFilterType.amount,
    _ExpenseFilterType.paymentMode,
  ];

  String _filterLabel(_ExpenseFilterType type) {
    final selectedIndex = _selectedFilters[type];
    if (selectedIndex == null) {
      return switch (type) {
        _ExpenseFilterType.date => 'Date',
        _ExpenseFilterType.status => 'Status',
        _ExpenseFilterType.amount => 'Amount',
        _ExpenseFilterType.paymentMode => 'Payment Mode',
      };
    }

    final labels = switch (type) {
      _ExpenseFilterType.date => const ['This Month', 'Last 30 days', 'Last 90 days'],
      _ExpenseFilterType.status => const ['Expense', 'Income'],
      _ExpenseFilterType.amount => const [
        'Up to ₹200',
        '₹200 - ₹500',
        '₹500 - ₹2,000',
        'Above ₹2,000',
      ],
      _ExpenseFilterType.paymentMode => const [
        'UPI',
        'Cash',
        'Card',
        'Net Banking',
        'Other',
      ],
    };
    return labels[selectedIndex];
  }

  List<_ExpenseFilterType> get _orderedFilters => [
    ..._filterOrder,
    ..._defaultFilterOrder.where((type) => !_filterOrder.contains(type)),
  ];

  DatabaseReference? _transactionsReference() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: realtimeDatabaseUrl,
    ).ref('users/${user.uid}/transactions');
  }

  List<_ExpenseTransaction> _filterTransactions(
    List<_ExpenseTransaction> transactions,
  ) {
    final now = DateTime.now();
    return transactions.where((transaction) {
      final date = transaction.date;
      final dateFilter = _selectedFilters[_ExpenseFilterType.date];
      if (dateFilter == 0 && (date.year != now.year || date.month != now.month)) {
        return false;
      }
      if (dateFilter == 1 &&
          (date.isAfter(now) || now.difference(date).inDays > 30)) {
        return false;
      }
      if (dateFilter == 2 &&
          (date.isAfter(now) || now.difference(date).inDays > 90)) {
        return false;
      }

      final statusFilter = _selectedFilters[_ExpenseFilterType.status];
      if (statusFilter != null &&
          transaction.type != (statusFilter == 0 ? 'expense' : 'income')) {
        return false;
      }

      final amountFilter = _selectedFilters[_ExpenseFilterType.amount];
      if (amountFilter == 0 && transaction.amount > 200) return false;
      if (amountFilter == 1 &&
          (transaction.amount <= 200 || transaction.amount > 500)) {
        return false;
      }
      if (amountFilter == 2 &&
          (transaction.amount <= 500 || transaction.amount > 2000)) {
        return false;
      }
      if (amountFilter == 3 && transaction.amount <= 2000) return false;

      final paymentFilter = _selectedFilters[_ExpenseFilterType.paymentMode];
      if (paymentFilter != null &&
          transaction.paymentMode.toLowerCase() !=
              const ['upi', 'cash', 'card', 'net banking', 'other'][paymentFilter]) {
        return false;
      }

      if (_searchQuery.isNotEmpty &&
          !transaction.title.toLowerCase().contains(_searchQuery) &&
          !transaction.category.toLowerCase().contains(_searchQuery) &&
          !transaction.paymentMode.toLowerCase().contains(_searchQuery)) {
        return false;
      }
      return true;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Widget _buildTransactionList() {
    return StreamBuilder<DatabaseEvent>(
      stream: _transactionsReference()?.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('Could not load transactions.')),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final transactions = _filterTransactions(
          _readExpenseTransactions(snapshot.data?.snapshot.value),
        );
        if (transactions.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No transactions found')),
          );
        }

        final groups = <DateTime, List<_ExpenseTransaction>>{};
        for (final transaction in transactions) {
          final date = transaction.date;
          final day = DateTime(date.year, date.month, date.day);
          groups.putIfAbsent(day, () => []).add(transaction);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _expenseGroupLabel(entry.key),
                  style: GoogleFonts.chewy(fontSize: 16),
                ),
              ),
              for (final transaction in entry.value)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TransactionTile(
                    type: transaction.type,
                    amount: transaction.amount,
                    date: transaction.date,
                    title: transaction.title,
                    paymentMode: transaction.paymentMode,
                    colorIndex: transaction.colorIndex,
                  ),
                ),
              const SizedBox(height: 4),
            ],
          ],
        );
      },
    );
  }

  Future<void> _openFilter(_ExpenseFilterType type) async {
    final selectedIndex = await _showExpenseFilterDialog(
      context,
      type,
      _selectedFilters[type],
      onClear: () {
        if (!mounted) return;
        setState(() {
          _selectedFilters.remove(type);
          _filterOrder.remove(type);
        });
      },
    );
    if (!mounted || selectedIndex == null) return;
    setState(() {
      _selectedFilters[type] = selectedIndex;
      _filterOrder.remove(type);
      _filterOrder.insert(0, type);
    });
  }

  void _openAddExpense(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AddExpenseScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      bottomNavigationBar: SafeArea(
        top: false,
        left: false,
        right: false,
        child: SizedBox(
          width: double.infinity,
          height: 84,
          child: CustomPaint(
            painter: const _ExpensesNotchedBarPainter(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _ExpensesBottomMenuItem(
                      label: 'Home',
                      icon: Icons.grid_view_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const Expanded(
                    child: _ExpensesBottomMenuItem(
                      label: 'Expenses',
                      icon: Icons.receipt_long_outlined,
                      selected: true,
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
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: _ExpensesBottomMenuItem(
                      label: 'Reports',
                      icon: Icons.analytics_outlined,
                    ),
                  ),
                  const Expanded(
                    child: _ExpensesBottomMenuItem(
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                      onPressed: () => _showDownloadDialog(context),
                      tooltip: 'Download transactions',
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF8078F9),
                        foregroundColor: Colors.white,
                        fixedSize: const Size(40, 40),
                      ),
                      icon: const Icon(Icons.download_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9E9E6),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: TextField(
                    textInputAction: TextInputAction.search,
                    onChanged: (value) =>
                        setState(() => _searchQuery = value.trim().toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search Transactions',
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final type in _orderedFilters)
                        _ExpenseFilterChip(
                          label: _filterLabel(type),
                          selected: _selectedFilters.containsKey(type),
                          onTap: () => _openFilter(type),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _buildTransactionList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<_ExpenseTransaction> _readExpenseTransactions(Object? value) {
  if (value is! Map) return [];

  final transactions = <_ExpenseTransaction>[];
  for (final entry in value.entries) {
    final raw = entry.value;
    if (raw is! Map) continue;
    final data = Map<String, dynamic>.from(raw);
    final amount = double.tryParse(data['amount']?.toString() ?? '');
    final timestamp = int.tryParse(data['createdAt']?.toString() ?? '');
    final type = data['type']?.toString().toLowerCase();
    if (amount == null || timestamp == null ||
        (type != 'expense' && type != 'income')) {
      continue;
    }
    transactions.add(
      _ExpenseTransaction(
        type: type!,
        amount: amount,
        date: DateTime.fromMillisecondsSinceEpoch(timestamp),
        title: data['title']?.toString().trim().isNotEmpty == true
            ? data['title'].toString().trim()
            : 'Transaction',
        category: data['category']?.toString() ?? '',
        paymentMode: data['paymentMode']?.toString() ?? '',
        id: entry.key.toString(),
        colorIndex: 0,
      ),
    );
  }
  transactions.sort((a, b) => a.id.compareTo(b.id));
  if (transactions.isNotEmpty) {
    final randomStart = transactions.first.id.hashCode % 3;
    for (var index = 0; index < transactions.length; index++) {
      transactions[index] = transactions[index].withColorIndex(
        (randomStart + index) % 3,
      );
    }
  }
  transactions.sort((a, b) => b.date.compareTo(a.date));
  return transactions;
}

String _expenseGroupLabel(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  const weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final dateLabel = '${date.day} ${months[date.month - 1]}';
  if (day == today) return 'Today, $dateLabel';
  if (day == today.subtract(const Duration(days: 1))) {
    return 'Yesterday, $dateLabel';
  }
  return '${weekdays[date.weekday - 1]}, $dateLabel';
}

class _ExpenseTransaction {
  const _ExpenseTransaction({
    required this.type,
    required this.amount,
    required this.date,
    required this.title,
    required this.category,
    required this.paymentMode,
    required this.id,
    required this.colorIndex,
  });

  final String type;
  final double amount;
  final DateTime date;
  final String title;
  final String category;
  final String paymentMode;
  final String id;
  final int colorIndex;

  _ExpenseTransaction withColorIndex(int index) => _ExpenseTransaction(
    type: type,
    amount: amount,
    date: date,
    title: title,
    category: category,
    paymentMode: paymentMode,
    id: id,
    colorIndex: index,
  );
}

class _ExpenseFilterChip extends StatelessWidget {
  const _ExpenseFilterChip({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? const Color(0xFF8078F9) : const Color(0xFFE9E9E6),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: selected ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: selected ? Colors.white : Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _ExpenseFilterType { date, status, amount, paymentMode }

class _ExpenseFilterOption {
  const _ExpenseFilterOption({
    required this.label,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.bold = false,
  });

  final String label;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final bool bold;
}

Future<void> _showDownloadDialog(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close download options',
    barrierColor: Colors.black.withValues(alpha: 0.38),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) =>
        const _DownloadDialog(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.linear));
      return SlideTransition(position: slide, child: child);
    },
  );
}

class _DownloadDialog extends StatefulWidget {
  const _DownloadDialog();

  @override
  State<_DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<_DownloadDialog> {
  static const Color _primaryColor = Color(0xFF8078F9);
  String _selectedDateRange = 'All Time';
  String _selectedFormat = '';

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: 420,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'Download Your Hisaab',
                      style: GoogleFonts.chewy(
                        fontSize: 22,
                        color: _primaryColor,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        constraints: const BoxConstraints.tightFor(
                          width: 40,
                          height: 40,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.close, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'Get a copy of all your transactions for your records.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Date Range',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              _buildDateRangeRow(const ['All Time', 'This Month', 'Last Month']),
              const SizedBox(height: 10),
              _buildDateRangeRow(const ['Last 3 Months', 'This Year', 'Custom']),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose File Format',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildFormatCard(
                      label: 'PDF',
                      subtitle: 'Easy to read & share',
                      icon: Icons.picture_as_pdf_rounded,
                      color: const Color(0xFFE53935),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormatCard(
                      label: 'Excel (.xlsx)',
                      subtitle: 'Easy to analyse',
                      icon: Icons.grid_on_rounded,
                      color: const Color(0xFF20A464),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Download Transaction',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeRow(List<String> labels) {
    return Row(
      children: [
        for (var index = 0; index < labels.length; index++) ...[
          if (index > 0) const SizedBox(width: 12),
          Expanded(
            child: _DownloadChoice(
              label: labels[index],
              selected: _selectedDateRange == labels[index],
              onTap: () => setState(() => _selectedDateRange = labels[index]),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFormatCard({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final format = label == 'PDF' ? 'PDF' : 'Excel';
    final selected = _selectedFormat == format;
    return GestureDetector(
      onTap: () => setState(() => _selectedFormat = format),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFD8D3EE) : Colors.white,
          border: Border.all(
            color: selected ? _primaryColor : Colors.black,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 27),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadChoice extends StatelessWidget {
  const _DownloadChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFD8D3EE) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF8078F9) : Colors.black,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}

Future<int?> _showExpenseFilterDialog(
  BuildContext context,
  _ExpenseFilterType type,
  int? selectedIndex, {
  required VoidCallback onClear,
}) {
  final title = switch (type) {
    _ExpenseFilterType.date => 'Date',
    _ExpenseFilterType.status => 'Status',
    _ExpenseFilterType.amount => 'Amount',
    _ExpenseFilterType.paymentMode => 'Payment Mode',
  };

  return showGeneralDialog<int?>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close $title filter',
    barrierColor: Colors.black.withValues(alpha: 0.28),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) =>
        _ExpenseFilterDialog(
          type: type,
          selectedIndex: selectedIndex,
          onClear: onClear,
        ),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: Curves.linear),
      );
      return SlideTransition(position: slide, child: child);
    },
  );
}

class _ExpenseFilterDialog extends StatefulWidget {
  const _ExpenseFilterDialog({
    required this.type,
    required this.onClear,
    this.selectedIndex,
  });

  final _ExpenseFilterType type;
  final int? selectedIndex;
  final VoidCallback onClear;

  @override
  State<_ExpenseFilterDialog> createState() => _ExpenseFilterDialogState();
}

class _ExpenseFilterDialogState extends State<_ExpenseFilterDialog> {
  static const Color _primaryColor = Color(0xFF8078F9);
  late final List<_ExpenseFilterOption> _options;
  int? _selectedIndex;

  String get _title => switch (widget.type) {
    _ExpenseFilterType.date => 'Date',
    _ExpenseFilterType.status => 'Status',
    _ExpenseFilterType.amount => 'Amount',
    _ExpenseFilterType.paymentMode => 'Payment Mode',
  };

  double get _panelHeight => switch (widget.type) {
    _ExpenseFilterType.date => 340,
    _ExpenseFilterType.status => 308,
    _ExpenseFilterType.amount => 378,
    _ExpenseFilterType.paymentMode => 418,
  };

  @override
  void initState() {
    super.initState();
    _options = switch (widget.type) {
      _ExpenseFilterType.date => const [
        _ExpenseFilterOption(label: 'This Month'),
        _ExpenseFilterOption(label: 'Last 30 days'),
        _ExpenseFilterOption(label: 'Last 90 days'),
      ],
      _ExpenseFilterType.status => const [
        _ExpenseFilterOption(
          label: 'Expense',
          icon: Icons.arrow_upward_rounded,
          iconColor: Color(0xFFFF6666),
          iconBackgroundColor: Color(0xFFFFE8E8),
        ),
        _ExpenseFilterOption(
          label: 'Income',
          icon: Icons.arrow_downward_rounded,
          iconColor: Color(0xFF39B65D),
          iconBackgroundColor: Color(0xFFE5F5E9),
        ),
      ],
      _ExpenseFilterType.amount => const [
        _ExpenseFilterOption(label: 'Up to ₹200', bold: true),
        _ExpenseFilterOption(label: '₹200 - ₹500', bold: true),
        _ExpenseFilterOption(label: '₹500 - ₹2,000', bold: true),
        _ExpenseFilterOption(label: 'Above ₹2,000', bold: true),
      ],
      _ExpenseFilterType.paymentMode => const [
        _ExpenseFilterOption(label: 'UPI', icon: Icons.qr_code_2),
        _ExpenseFilterOption(label: 'Cash', icon: Icons.payments_outlined),
        _ExpenseFilterOption(label: 'Card', icon: Icons.credit_card_outlined),
        _ExpenseFilterOption(
          label: 'Net Banking',
          icon: Icons.account_balance_outlined,
        ),
        _ExpenseFilterOption(label: 'Other', icon: Icons.more_horiz),
      ],
    };
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: _panelHeight,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 42,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      _title,
                      style: GoogleFonts.chewy(
                        fontSize: 22,
                        color: _primaryColor,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        constraints: const BoxConstraints.tightFor(
                          width: 40,
                          height: 40,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.close, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Column(
                  children: [
                    for (var index = 0; index < _options.length; index++)
                      _buildOptionRow(index),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_selectedIndex),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Apply Filter',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _selectedIndex = null);
                    widget.onClear();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryColor,
                    side: const BorderSide(color: _primaryColor),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Clear All',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionRow(int index) {
    final option = _options[index];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selectedIndex = index),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            if (option.icon != null) ...[
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: option.iconBackgroundColor ?? _primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  option.icon,
                  size: 14,
                  color: option.iconColor ?? Colors.white,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: option.bold ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ),
            Checkbox(
              value: _selectedIndex == index,
              onChanged: (value) {
                if (value == true) setState(() => _selectedIndex = index);
              },
              fillColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? _primaryColor
                    : const Color(0xFFD9D9D9);
              }),
              checkColor: Colors.white,
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpensesBottomMenuItem extends StatelessWidget {
  const _ExpensesBottomMenuItem({
    required this.label,
    required this.icon,
    this.selected = false,
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
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpensesNotchedBarPainter extends CustomPainter {
  const _ExpensesNotchedBarPainter();

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
    canvas.drawPath(
      path,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _ExpensesNotchedBarPainter oldDelegate) => false;
}
