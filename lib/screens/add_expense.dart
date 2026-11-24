import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  static const Color _backgroundColor = Color(0xFFFAFAF3);
  static const Color _primaryColor = Color(0xFF8078F9);
  static const Color _yellowColor = Color(0xFFFFDD32);

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isExpense = true;
  String _selectedCategory = 'Food';
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
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
                          _TransactionTypeButton(
                            label: 'Expense',
                            selected: _isExpense,
                            onTap: () => setState(() => _isExpense = true),
                          ),
                          _TransactionTypeButton(
                            label: 'Income',
                            selected: !_isExpense,
                            onTap: () => setState(() => _isExpense = false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                      decoration: BoxDecoration(
                        color: _yellowColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.payments_outlined, size: 19),
                              SizedBox(width: 9),
                              Text(
                                'Enter Amount',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
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
                                  color: Color(0xFF9A8120),
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
                                    color: Color(0xFF806B18),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0.00',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF9A8120),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 2,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(11),
                                      borderSide: const BorderSide(
                                        color: Color.fromRGBO(0, 0, 0, 0.25),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(11),
                                      borderSide: BorderSide(
                                        color: Colors.black.withValues(
                                          alpha: 0.25,
                                        ),
                                        width: 3,
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
                            style: TextStyle(fontSize: 13),
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
                          const Text('Title of expense', style: TextStyle(fontWeight: FontWeight.w500),),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _titleController,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Enter a title',
                              filled: true,
                              fillColor: const Color(0xFFFFF5CF),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 17,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text('Description (Optional)',style: TextStyle(fontWeight: FontWeight.w500),),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _descriptionController,
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 3,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Add a description',
                              filled: true,
                              fillColor: const Color(0xFFFFF5CF),
                              contentPadding: const EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                                borderSide: BorderSide.none,
                              ),
                            ),
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
                          const Text('Category',style: TextStyle(fontWeight: FontWeight.w500),),
                          const SizedBox(height: 10),
                          GridView.count(
                            crossAxisCount: 4,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.9,
                            children: [
                              _CategoryOption(
                                label: 'Food',
                                icon: Icons.restaurant,
                                selected: _selectedCategory == 'Food',
                                onTap: () => setState(
                                  () => _selectedCategory = 'Food',
                                ),
                              ),
                              _CategoryOption(
                                label: 'Groceries',
                                icon: Icons.shopping_cart_outlined,
                                selected: _selectedCategory == 'Groceries',
                                onTap: () => setState(
                                  () => _selectedCategory = 'Groceries',
                                ),
                              ),
                              _CategoryOption(
                                label: 'Shopping',
                                icon: Icons.shopping_bag_outlined,
                                selected: _selectedCategory == 'Shopping',
                                onTap: () => setState(
                                  () => _selectedCategory = 'Shopping',
                                ),
                              ),
                              _CategoryOption(
                                label: 'Travel',
                                icon: Icons.directions_car_outlined,
                                selected: _selectedCategory == 'Travel',
                                onTap: () => setState(
                                  () => _selectedCategory = 'Travel',
                                ),
                              ),
                              _CategoryOption(
                                label: 'Bills',
                                icon: Icons.receipt_long_outlined,
                                selected: _selectedCategory == 'Bills',
                                onTap: () => setState(
                                  () => _selectedCategory = 'Bills',
                                ),
                              ),
                              _CategoryOption(
                                label: 'Medical',
                                icon: Icons.medical_services_outlined,
                                selected: _selectedCategory == 'Medical',
                                onTap: () => setState(
                                  () => _selectedCategory = 'Medical',
                                ),
                              ),
                              _CategoryOption(
                                label: 'Entertainment',
                                icon: Icons.movie_outlined,
                                selected: _selectedCategory == 'Entertainment',
                                onTap: () => setState(
                                  () => _selectedCategory = 'Entertainment',
                                ),
                              ),
                              _CategoryOption(
                                label: 'Other',
                                icon: Icons.more_horiz,
                                selected: _selectedCategory == 'Other',
                                onTap: () => setState(
                                  () => _selectedCategory = 'Other',
                                ),
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
                        const Text(
                          'Date & Time',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _DateTimePickerField(
                                label: 'Date',
                                value: _dateLabel,
                                icon: Icons.calendar_today_outlined,
                                onTap: _pickDate,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _DateTimePickerField(
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

class _DateTimePickerField extends StatelessWidget {
  const _DateTimePickerField({
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

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
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
          color: selected ? const Color(0xFFFFDD32) : const Color(0xFFF4F3ED),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 23),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTypeButton extends StatelessWidget {
  const _TransactionTypeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFDD32) : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
