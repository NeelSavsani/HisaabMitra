import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:hisaabmitra/config/database_config.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({
    super.key,
    required this.userId,
    required this.transactionId,
  });

  final String userId;
  final String transactionId;

  @override
  Widget build(BuildContext context) {
    final transaction = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: realtimeDatabaseUrl,
    ).ref('users/$userId/transactions/$transactionId');

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF3),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, size: 19),
                  label: const Text('Edit Transaction'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8078F9),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.delete_outline, size: 19),
                  label: const Text('Delete Transaction'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Color(0xFFE2DED4)),
                    elevation: 1,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const Expanded(
                    child: Text(
                      'Transaction Details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.share_outlined),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE7E3D3)),
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: transaction.onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(
                      child: Text('Could not load transaction details.'),
                    );
                  }

                  final value = snapshot.data!.snapshot.value;
                  if (value is! Map) {
                    return const Center(child: Text('Transaction not found.'));
                  }
                  final data = Map<String, dynamic>.from(value);
                  final type = data['type']?.toString().toLowerCase() ?? 'expense';
                  final isIncome = type == 'income';
                  final amount =
                      double.tryParse(data['amount']?.toString() ?? '') ?? 0;
                  final timestamp =
                      int.tryParse(data['createdAt']?.toString() ?? '') ?? 0;
                  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
                  final title = data['title']?.toString() ?? 'Transaction';
                  final category = data['category']?.toString() ?? 'Other';
                  final paymentMode =
                      data['paymentMode']?.toString() ?? 'Not specified';
                  final description = data['description']?.toString() ?? '';
                  final accent = isIncome
                      ? const Color(0xFF6D63E8)
                      : const Color(0xFFFFDD32);
                  final foreground = isIncome
                      ? Colors.white
                      : const Color(0xFF806B18);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _TransactionAmountCard(
                          isIncome: isIncome,
                          amount: amount,
                          category: category,
                          backgroundColor: accent,
                          foregroundColor: foreground,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.info_rounded,
                                    size: 19,
                                    color: Color(0xFF494949),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Payment Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 18, color: Color(0xFFE8E4DA)),
                              _DetailRow(
                                icon: Icons.badge_outlined,
                                label: 'Hisaab ID',
                                value: transactionId,
                              ),
                              _DetailRow(
                                icon: Icons.assignment_outlined,
                                label: 'Title',
                                value: title,
                              ),
                              _DetailRow(
                                icon: Icons.category_outlined,
                                label: 'Category',
                                value: category,
                              ),
                              _DetailRow(
                                icon: Icons.calendar_month_outlined,
                                label: 'Date and Time',
                                value: _formatDateTime(date),
                              ),
                              _DetailRow(
                                icon: Icons.credit_card_outlined,
                                label: 'Payment Mode',
                                value: paymentMode,
                              ),
                              const Divider(height: 18, color: Color(0xFFE8E4DA)),
                              const Row(
                                children: [
                                  Icon(Icons.description_outlined, size: 17),
                                  SizedBox(width: 7),
                                  Text(
                                    'Description / Memo',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F3ED),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  description.isEmpty
                                      ? 'No description added.'
                                      : description,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionAmountCard extends StatelessWidget {
  const _TransactionAmountCard({
    required this.isIncome,
    required this.amount,
    required this.category,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final bool isIncome;
  final double amount;
  final String category;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final amountParts = _formatAmount(amount).split('.');
    return Container(
      height: 177,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isIncome ? const Color(0xFF20A340) : Colors.red,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 5),
                Text(
                  isIncome ? 'Income' : 'Expense',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: foregroundColor,
                fontSize: 40,
                fontWeight: FontWeight.w700,
              ),
              children: [
                TextSpan(text: '${isIncome ? '+' : '−'}₹${amountParts.first}'),
                TextSpan(
                  text: '.${amountParts.length > 1 ? amountParts[1] : '00'}',
                  style: TextStyle(
                    color: foregroundColor.withValues(alpha: 0.65),
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_categoryIcon(category), size: 18, color: Colors.black54),
                const SizedBox(width: 7),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 17, color: const Color(0xFF494949)),
          const SizedBox(width: 8),
          SizedBox(
            width: 102,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _categoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return Icons.restaurant;
    case 'groceries':
      return Icons.shopping_cart_outlined;
    case 'shopping':
      return Icons.shopping_bag_outlined;
    case 'travel':
      return Icons.directions_car_outlined;
    case 'bills':
      return Icons.receipt_long_outlined;
    case 'medical':
      return Icons.medical_services_outlined;
    case 'salary':
      return Icons.payments_outlined;
    case 'business':
      return Icons.business_center_outlined;
    case 'investment':
      return Icons.trending_up;
    case 'rental':
      return Icons.house_outlined;
    case 'gift':
      return Icons.card_giftcard_outlined;
    default:
      return Icons.category_outlined;
  }
}

String _formatDateTime(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '${date.day} ${months[date.month - 1]} ${date.year}, '
      '${hour.toString().padLeft(2, '0')}:$minute $period';
}

String _formatAmount(double amount) {
  final fixed = amount.toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts.first;
  if (whole.length <= 3) return fixed;

  final groups = <String>[];
  var remaining = whole;
  groups.insert(0, remaining.substring(remaining.length - 3));
  remaining = remaining.substring(0, remaining.length - 3);
  while (remaining.length > 2) {
    groups.insert(0, remaining.substring(remaining.length - 2));
    remaining = remaining.substring(0, remaining.length - 2);
  }
  if (remaining.isNotEmpty) groups.insert(0, remaining);
  return '${groups.join(',')}.${parts[1]}';
}
