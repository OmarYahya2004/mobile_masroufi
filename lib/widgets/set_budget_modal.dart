import 'package:flutter/material.dart';
import '../data/models/expense.dart';
import '../core/constants/colors.dart';
import '../core/constants/constants.dart';

class SetBudgetModal extends StatefulWidget {
  final Function(ExpenseCategory, double) onSave;

  const SetBudgetModal({super.key, required this.onSave});

  @override
  State<SetBudgetModal> createState() => _SetBudgetModalState();
}

class _SetBudgetModalState extends State<SetBudgetModal> {
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  final _amountController = TextEditingController();
  final String appFont = AppConstants.appFont;

  @override
  void dispose() {
    _amountController.dispose();
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
    final dropdownBgColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final focusedBorderColor =
        isDark ? AppColors.accentCyan : AppColors.primaryTeal;

    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: keyboardSpace + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Set budget limit',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.primaryBlue,
                fontFamily: appFont,
              ),
            ),
            const SizedBox(height: 24),

            // 1. Category Dropdown
            Text(
              'Category',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
                fontFamily: appFont,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: inputFillColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ExpenseCategory>(
                  value: _selectedCategory,
                  isExpanded: true,
                  dropdownColor: dropdownBgColor,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: secondaryTextColor,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  items: ExpenseCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Row(
                        children: [
                          Text(
                            AppConstants.getCategoryIcon(cat),
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppConstants.getCategoryName(cat),
                            style: TextStyle(
                              color: textColor,
                              fontFamily: appFont,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Monthly Limit Input
            Text(
              'Monthly limit (EGP)',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
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
                hintStyle: TextStyle(
                  color: secondaryTextColor,
                  fontFamily: appFont,
                ),
                filled: true,
                fillColor: inputFillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 3. Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: secondaryTextColor.withValues(alpha: 0.5),
                      ),
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
                    onPressed: () {
                      final amount = double.tryParse(_amountController.text);
                      if (amount != null && amount > 0) {
                        widget.onSave(_selectedCategory, amount);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Save goal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: appFont,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}