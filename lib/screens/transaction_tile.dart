import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.type,
    required this.amount,
    required this.date,
    required this.title,
    required this.paymentMode,
    required this.colorIndex,
    this.onTap,
  });

  final String type;
  final double amount;
  final DateTime date;
  final String title;
  final String paymentMode;
  final int colorIndex;
  final VoidCallback? onTap;

  static const _palettes = [
    _TransactionPalette(Color(0xFFD8D3EE), Color(0xFF8078F9)),
    _TransactionPalette(Color(0xFFFDDC35), Color(0xFF000000)),
    _TransactionPalette(Color(0xFFDEDEDD), Color(0xFF000000)),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = _palettes[colorIndex % _palettes.length];
    final isIncome = type == 'income';
    final payment = paymentMode;
    final paymentColor = payment.toLowerCase() == 'upi'
        ? const Color(0xFFFFDD32)
        : payment.toLowerCase() == 'cash'
        ? const Color(0xFFE0DCFF)
        : const Color(0xFFE2E2E2);
    final titleInitial = title.trim().isEmpty ? 'T' : title.trim()[0].toUpperCase();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: palette.background,
            child: Text(
              titleInitial,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: palette.foreground,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${date.day} ${_fullMonth(date.month)}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    const SizedBox(width: 6),
                    if (payment.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxWidth: 78),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: paymentColor,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          payment.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 2),
          Text(
            '${isIncome ? '+' : '−'} ₹${_formatAmount(amount)}',
            maxLines: 1,
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _TransactionPalette {
  const _TransactionPalette(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

String _fullMonth(int month) => const [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
][month - 1];

String _formatAmount(double amount) {
  final fixed = amount == amount.truncateToDouble()
      ? amount.toInt().toString()
      : amount.toStringAsFixed(2);
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
  return '${groups.join(',')}${parts.length > 1 ? '.${parts[1]}' : ''}';
}
