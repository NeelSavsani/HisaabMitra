import 'package:flutter/material.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key, this.onSwitchToExpense});

  final VoidCallback? onSwitchToExpense;

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  static const Color _backgroundColor = Color(0xFFFAFAF3);
  static const Color _incomeColor = Color(0xFF8078F9);

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Salary';
  String _selectedPaymentMode = 'UPI';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    FocusScope.of(context).unfocus();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  String get _dateLabel {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    final isToday =
        _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
    final date = '${_selectedDate.day} ${months[_selectedDate.month - 1]}';
    return isToday ? 'Today, $date' : '$date ${_selectedDate.year}';
  }

  String get _timeLabel {
    final hour = _selectedTime.hourOfPeriod == 0
        ? 12
        : _selectedTime.hourOfPeriod;
    final minute = _selectedTime.minute.toString().padLeft(2, '0');
    final period = _selectedTime.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Back to dashboard',
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const Expanded(
                    child: Text(
                      'Add Transaction',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE7E3D3)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9E9E6),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _IncomeTypeTab(
                              label: 'Expense',
                              selected: false,
                              onTap: widget.onSwitchToExpense ?? () {},
                            ),
                          ),
                          const Expanded(
                            child: _IncomeTypeTab(
                              label: 'Income',
                              selected: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                      decoration: BoxDecoration(
                        color: _incomeColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.payments_outlined,
                                size: 19,
                                color: Colors.white,
                              ),
                              SizedBox(width: 9),
                              Text(
                                'Enter Amount',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                '₹',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _amountController,
                                  onTapOutside: (_) =>
                                      FocusScope.of(context).unfocus(),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  cursorHeight: 42,
                                  style: const TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0.00',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFFE7E4FF),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 2,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(11),
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(11),
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Clear, Straightforward Record For Your Wallet',
                            style: TextStyle(fontSize: 13, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFEFECE2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Title of income'),
                          const SizedBox(height: 8),
                          _IncomeTextField(
                            controller: _titleController,
                            hint: 'Enter a title',
                          ),
                          const SizedBox(height: 12),
                          const Text('Description (Optional)'),
                          const SizedBox(height: 8),
                          _IncomeTextField(
                            controller: _descriptionController,
                            hint: 'Add a description',
                            minLines: 3,
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFEFECE2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Category'),
                          const SizedBox(height: 10),
                          GridView.count(
                            crossAxisCount: 4,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.9,
                            children: [
                              _IncomeCategoryOption(
                                label: 'Salary',
                                icon: Icons.payments_outlined,
                                selected: _selectedCategory == 'Salary',
                                onTap: () => setState(
                                  () => _selectedCategory = 'Salary',
                                ),
                              ),
                              _IncomeCategoryOption(
                                label: 'Groceries',
                                icon: Icons.laptop_chromebook_outlined,
                                selected: _selectedCategory == 'Groceries',
                                onTap: () => setState(
                                  () => _selectedCategory = 'Groceries',
                                ),
                              ),
                              _IncomeCategoryOption(
                                label: 'Pocket Money',
                                icon: Icons.groups_2_outlined,
                                selected: _selectedCategory == 'Pocket Money',
                                onTap: () => setState(
                                  () => _selectedCategory = 'Pocket Money',
                                ),
                              ),
                              _IncomeCategoryOption(
                                label: 'Investment',
                                icon: Icons.trending_up,
                                selected: _selectedCategory == 'Investment',
                                onTap: () => setState(
                                  () => _selectedCategory = 'Investment',
                                ),
                              ),
                              _IncomeCategoryOption(
                                label: 'Rental',
                                icon: Icons.house_outlined,
                                selected: _selectedCategory == 'Rental',
                                onTap: () => setState(
                                  () => _selectedCategory = 'Rental',
                                ),
                              ),
                              _IncomeCategoryOption(
                                label: 'Business',
                                icon: Icons.storefront_outlined,
                                selected: _selectedCategory == 'Business',
                                onTap: () => setState(
                                  () => _selectedCategory = 'Business',
                                ),
                              ),
                              _IncomeCategoryOption(
                                label: 'Gift',
                                icon: Icons.card_giftcard_outlined,
                                selected: _selectedCategory == 'Gift',
                                onTap: () =>
                                    setState(() => _selectedCategory = 'Gift'),
                              ),
                              _IncomeCategoryOption(
                                label: 'Other',
                                icon: Icons.more_horiz,
                                selected: _selectedCategory == 'Other',
                                onTap: () =>
                                    setState(() => _selectedCategory = 'Other'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date & Time'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _IncomeDateTimeField(
                                label: 'Date',
                                value: _dateLabel,
                                icon: Icons.calendar_today_outlined,
                                onTap: _pickDate,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _IncomeDateTimeField(
                                label: 'Time',
                                value: _timeLabel,
                                icon: Icons.access_time,
                                onTap: _pickTime,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFEFECE2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.credit_card_outlined,
                                size: 18,
                                color: Color(0xFF796B24),
                              ),
                              SizedBox(width: 7),
                              Text(
                                'Payment Mode',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final mode in const [
                                ('UPI', Icons.qr_code_2),
                                ('Cash', Icons.payments_outlined),
                                ('Card', Icons.credit_card_outlined),
                                ('Net Banking', Icons.account_balance_outlined),
                                ('Other', Icons.more_horiz),
                              ])
                                _IncomePaymentModeOption(
                                  label: mode.$1,
                                  icon: mode.$2,
                                  selected: _selectedPaymentMode == mode.$1,
                                  onTap: () => setState(
                                    () => _selectedPaymentMode = mode.$1,
                                  ),
                                ),
                            ],
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
      ),
    );
  }
}

class _IncomeTypeTab extends StatelessWidget {
  const _IncomeTypeTab({
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _AddIncomeStateColors.income : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

abstract final class _AddIncomeStateColors {
  static const Color income = Color(0xFF8078F9);
}

class _IncomeTextField extends StatelessWidget {
  const _IncomeTextField({
    required this.controller,
    required this.hint,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF4F3ED),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _IncomeCategoryOption extends StatelessWidget {
  const _IncomeCategoryOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF8078F9) : const Color(0xFFF4F3ED),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 21, color: selected ? Colors.white : Colors.black),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: selected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomeDateTimeField extends StatelessWidget {
  const _IncomeDateTimeField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFFE7E3D3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6E622C), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7A735D),
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
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

class _IncomePaymentModeOption extends StatelessWidget {
  const _IncomePaymentModeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF8078F9) : const Color(0xFFF4F3ED),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? Colors.white : const Color(0xFF796B24),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                color: selected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
