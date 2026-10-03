import 'package:flutter/material.dart';
import '../data/models/expense.dart';
import '../core/constants/colors.dart';
import '../core/constants/constants.dart';

class AddExpenseModal extends StatefulWidget {
  final void Function(Expense expense) onAddExpense;
  final Expense? initialExpense; // Optional: pass an expense here to Edit instead of Add

  const AddExpenseModal({
    super.key,
    required this.onAddExpense,
    this.initialExpense,
  });

  @override
  State<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  DateTime _selectedDate = DateTime.now();

  final String appFont = AppConstants.appFont;

  bool get _isEditing => widget.initialExpense != null;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields if we are editing an existing expense
    if (_isEditing) {
      final exp = widget.initialExpense!;
      _amountController.text = exp.amount.toStringAsFixed(0);
      _noteController.text = exp.note ?? '';
      _selectedCategory = exp.category;
      _selectedDate = exp.date;
    }
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.primaryTeal,
                    onPrimary: Colors.white,
                    surface: AppColors.darkSurface,
                    onSurface: AppColors.darkText,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primaryBlue,
                    onPrimary: Colors.white,
                    surface: AppColors.lightSurface,
                    onSurface: AppColors.lightText,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _submitData() {
    final enteredAmount = double.tryParse(_amountController.text);
    if (enteredAmount == null || enteredAmount <= 0) return;

    final expense = Expense(
      id: _isEditing ? widget.initialExpense!.id : DateTime.now().toString(),
      amount: enteredAmount,
      category: _selectedCategory,
      note: _noteController.text.trim(),
      date: _selectedDate,
    );

    widget.onAddExpense(expense);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final secondaryTextColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final inputFillColor =
        isDark ? AppColors.darkInputFill : AppColors.lightInputFill;
    final selectedBorderColor =
        isDark ? AppColors.accentCyan : AppColors.primaryTeal;

    final formattedDate =
        '${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.year}';

    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? 'Edit expense' : 'Add expense',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.primaryBlue,
                fontFamily: appFont,
              ),
            ),
            const SizedBox(height: 16),

            // 1. Amount Field
            Text(
              'Amount (EGP)',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 12,
                fontFamily: appFont,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textColor, fontFamily: appFont),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: secondaryTextColor, fontFamily: appFont),
                filled: true,
                fillColor: inputFillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: selectedBorderColor, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Category Selection (3-column Grid)
            Text(
              'Category',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 12,
                fontFamily: appFont,
              ),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              itemCount: ExpenseCategory.values.length,
              itemBuilder: (context, index) {
                final category = ExpenseCategory.values[index];
                final isSelected = _selectedCategory == category;

                return InkWell(
                  onTap: () {
                    setState(() => _selectedCategory = category);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryTeal.withValues(alpha: 0.15)
                          : inputFillColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? selectedBorderColor : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppConstants.getCategoryIcon(category),
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppConstants.getCategoryName(category),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12,
                            fontFamily: appFont,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // 3. Note Field
            Text(
              'Note (optional)',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 12,
                fontFamily: appFont,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              keyboardType: TextInputType.text,
              style: TextStyle(color: textColor, fontFamily: appFont),
              decoration: InputDecoration(
                hintText: 'e.g. Uber to campus',
                hintStyle: TextStyle(color: secondaryTextColor, fontFamily: appFont),
                filled: true,
                fillColor: inputFillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: selectedBorderColor, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 4. Date Picker Field
            Text(
              'Date',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 12,
                fontFamily: appFont,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _presentDatePicker,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: inputFillColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontFamily: appFont,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.primaryTeal,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: secondaryTextColor.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: textColor,
                        fontFamily: appFont,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isEditing ? 'Update expense' : 'Save expense',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: appFont,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}