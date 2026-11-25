import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hisaabmitra/config/database_config.dart';

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
  final ScrollController _scrollController = ScrollController();
  bool _isExpense = true;
  String _selectedCategory = 'Food';
  String _selectedPaymentMode = 'UPI';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _hasReachedEnd = false;
  bool _isSaving = false;

  Future<void> _saveTransaction() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || !amount.isFinite || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount to continue.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to save this transaction.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final transactionDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: realtimeDatabaseUrl,
      );
      await database.ref('users/${user.uid}/transactions').push().set({
        'type': _isExpense ? 'expense' : 'income',
        'amount': amount,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'paymentMode': _selectedPaymentMode,
        // The dashboard uses createdAt for monthly totals and recent ordering.
        'createdAt': transactionDate.millisecondsSinceEpoch,
        'savedAt': ServerValue.timestamp,
      });

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save transaction: ${error.message ?? error.code}')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save transaction: $error')),
      );
    }
  }

  void _selectTransactionType(bool isExpense) {
    if (_isExpense == isExpense) return;

    FocusScope.of(context).unfocus();
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    setState(() {
      _isExpense = isExpense;
      _selectedCategory = isExpense ? 'Food' : 'Salary';
      _hasReachedEnd = false;
    });
  }

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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: _hasReachedEnd
                  ? [
                      BoxShadow(
                        offset: const Offset(0, 10),
                        blurRadius: 15,
                        spreadRadius: -3,
                        color: Colors.black.withValues(alpha: 0.1),
                      ),
                      BoxShadow(
                        offset: const Offset(0, 4),
                        blurRadius: 6,
                        spreadRadius: -4,
                        color: Colors.black.withValues(alpha: 0.1),
                      ),
                    ]
                  : const [],
            ),
            child: SizedBox(
              height: 54,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _hasReachedEnd && !_isSaving
                    ? _saveTransaction
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isExpense ? _yellowColor : _primaryColor,
                  foregroundColor: _isExpense ? Colors.black : Colors.white,
                  disabledBackgroundColor: const Color(0xFFC6C6C6),
                  disabledForegroundColor: const Color(0xFF8D8D8D),
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 8),
                    Text(
                      _isExpense ? 'Save Expense' : 'Save Income',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (!_hasReachedEnd &&
                      notification.metrics.axis == Axis.vertical &&
                      notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent) {
                    setState(() => _hasReachedEnd = true);
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
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
                            selectedColor: _yellowColor,
                            onTap: () => _selectTransactionType(true),
                          ),
                          _TransactionTypeButton(
                            label: 'Income',
                            selected: !_isExpense,
                            selectedColor: _primaryColor,
                            selectedForegroundColor: Colors.white,
                            onTap: () => _selectTransactionType(false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                      decoration: BoxDecoration(
                        color: _isExpense ? _yellowColor : _primaryColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.payments_outlined,
                                size: 19,
                                color: _isExpense ? Colors.black : Colors.white,
                              ),
                              SizedBox(width: 9),
                              Text(
                                'Enter Amount',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: _isExpense ? Colors.black : Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '₹',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: _isExpense
                                      ? const Color(0xFF9A8120)
                                      : Colors.white,
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
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: _isExpense
                                        ? const Color(0xFF806B18)
                                        : Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0.00',
                                    hintStyle: TextStyle(
                                      color: _isExpense
                                          ? const Color(0xFF9A8120)
                                          : const Color(0xFFE7E4FF),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 2,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(11),
                                      borderSide: BorderSide(
                                        color: _isExpense
                                            ? const Color.fromRGBO(0, 0, 0, 0.25)
                                            : Colors.white.withValues(alpha: 0.7),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(11),
                                      borderSide: BorderSide(
                                        color: _isExpense
                                            ? Colors.black.withValues(alpha: 0.25)
                                            : Colors.white.withValues(alpha: 0.7),
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Clear, Straightforward Record For Your Wallet',
                            style: TextStyle(
                              fontSize: 13,
                              color: _isExpense ? Colors.black : Colors.white,
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
                          Text(
                            _isExpense ? 'Title of expense' : 'Title of income',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _titleController,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Enter a title',
                              filled: true,
                              fillColor: const Color(0xFFF5F4ED),
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
                              fillColor: const Color(0xFFF5F4ED),
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
                            children: _isExpense ? [
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
                            ] : [
                              _CategoryOption(label: 'Salary', icon: Icons.payments_outlined, selected: _selectedCategory == 'Salary', selectedColor: _primaryColor, selectedForegroundColor: Colors.white, onTap: () => setState(() => _selectedCategory = 'Salary')),
                              _CategoryOption(label: 'Groceries', icon: Icons.laptop_chromebook_outlined, selected: _selectedCategory == 'Groceries', selectedColor: _primaryColor, selectedForegroundColor: Colors.white, onTap: () => setState(() => _selectedCategory = 'Groceries')),
                              _CategoryOption(label: 'Pocket Money', icon: Icons.groups_2_outlined, selected: _selectedCategory == 'Pocket Money', selectedColor: _primaryColor, selectedForegroundColor: Colors.white, onTap: () => setState(() => _selectedCategory = 'Pocket Money')),
                              _CategoryOption(label: 'Investment', icon: Icons.trending_up, selected: _selectedCategory == 'Investment', selectedColor: _primaryColor, selectedForegroundColor: Colors.white, onTap: () => setState(() => _selectedCategory = 'Investment')),
                              _CategoryOption(label: 'Rental', icon: Icons.house_outlined, selected: _selectedCategory == 'Rental', selectedColor: _primaryColor, selectedForegroundColor: Colors.white, onTap: () => setState(() => _selectedCategory = 'Rental')),
                              _CategoryOption(label: 'Business', icon: Icons.storefront_outlined, selected: _selectedCategory == 'Business', selectedColor: _primaryColor, selectedForegroundColor: Colors.white, onTap: () => setState(() => _selectedCategory = 'Business')),
                              _CategoryOption(label: 'Gift', icon: Icons.card_giftcard_outlined, selected: _selectedCategory == 'Gift', selectedColor: _primaryColor, selectedForegroundColor: Colors.white, onTap: () => setState(() => _selectedCategory = 'Gift')),
                              _CategoryOption(label: 'Other', icon: Icons.more_horiz, selected: _selectedCategory == 'Other', selectedColor: _primaryColor, selectedForegroundColor: Colors.white, onTap: () => setState(() => _selectedCategory = 'Other')),
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
                              _PaymentModeOption(
                                label: 'UPI',
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.w500
                                ),
                                icon: Icons.qr_code_2,
                                selected: _selectedPaymentMode == 'UPI',
                                incomeMode: !_isExpense,
                                onTap: () => setState(
                                  () => _selectedPaymentMode = 'UPI',
                                ),
                              ),
                              _PaymentModeOption(
                                label: 'Cash',
                                labelStyle: TextStyle(
                                    fontWeight: FontWeight.w500
                                ),
                                icon: Icons.payments_outlined,
                                selected: _selectedPaymentMode == 'Cash',
                                incomeMode: !_isExpense,
                                onTap: () => setState(
                                  () => _selectedPaymentMode = 'Cash',
                                ),
                              ),
                              _PaymentModeOption(
                                label: 'Card',
                                labelStyle: TextStyle(
                                    fontWeight: FontWeight.w500
                                ),
                                icon: Icons.credit_card_outlined,
                                selected: _selectedPaymentMode == 'Card',
                                incomeMode: !_isExpense,
                                onTap: () => setState(
                                  () => _selectedPaymentMode = 'Card',
                                ),
                              ),
                              _PaymentModeOption(
                                label: 'Net Banking',
                                labelStyle: TextStyle(
                                    fontWeight: FontWeight.w500
                                ),
                                icon: Icons.account_balance_outlined,
                                selected:
                                    _selectedPaymentMode == 'Net Banking',
                                incomeMode: !_isExpense,
                                onTap: () => setState(
                                  () => _selectedPaymentMode = 'Net Banking',
                                ),
                              ),
                              _PaymentModeOption(
                                label: 'Other',
                                labelStyle: TextStyle(
                                    fontWeight: FontWeight.w500
                                ),
                                icon: Icons.more_horiz,
                                selected: _selectedPaymentMode == 'Other',
                                incomeMode: !_isExpense,
                                onTap: () => setState(
                                  () => _selectedPaymentMode = 'Other',
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
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentModeOption extends StatelessWidget {
  const _PaymentModeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.labelStyle,
    this.incomeMode = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final TextStyle labelStyle;
  final bool incomeMode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (incomeMode ? const Color(0xFF8078F9) : const Color(0xFFFFDD32))
              : const Color(0xFFF4F3ED),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected && incomeMode
                  ? Colors.white
                  : const Color(0xFF796B24),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: labelStyle.copyWith(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                color: selected && incomeMode ? Colors.white : Colors.black,
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
    this.selectedColor = const Color(0xFFFFDD32),
    this.selectedForegroundColor = Colors.black,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color selectedForegroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? selectedColor : const Color(0xFFF4F3ED),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 23,
              color: selected ? selectedForegroundColor : Colors.black,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: selected ? selectedForegroundColor : Colors.black,
              ),
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
    this.selectedColor = const Color(0xFFFFDD32),
    this.selectedForegroundColor = Colors.black,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color selectedForegroundColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: selected ? selectedForegroundColor : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
