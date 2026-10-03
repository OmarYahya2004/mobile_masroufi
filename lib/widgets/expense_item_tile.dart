import 'package:flutter/material.dart';

import '../data/models/expense.dart';
import '../data/remote/firebase_service.dart';
import '../core/constants/colors.dart';
import 'add_expense_modal.dart';

class ExpenseItemTile extends StatelessWidget {
  final Expense expense;
  final Future<void> Function() onDelete;
  final Future<void> Function(Expense updatedExpense)? onEdit;
  final bool showCard; // true for HomePage, false for HistoryPage
  final String appFont;

  const ExpenseItemTile({
    super.key,
    required this.expense,
    required this.onDelete,
    this.onEdit,
    this.showCard = true,
    this.appFont = 'Poppins',
  });

  void _openEditExpenseOverlay(BuildContext context, Color surfaceColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => AddExpenseModal(
        initialExpense: expense, // Pre-fills the modal with existing data
        onAddExpense: (updatedExpense) async {
          if (onEdit != null) {
            await onEdit!(updatedExpense);
          } else {
            await FirebaseService().updateExpense(updatedExpense);
          }
        },
      ),
    );
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    Color surfaceColor,
    Color textColor,
    Color textSecondary,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Expense',
          style: TextStyle(
            color: textColor,
            fontFamily: appFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this expense?',
          style: TextStyle(
            color: textSecondary,
            fontFamily: appFont,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.primaryTeal,
                fontFamily: appFont,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: AppColors.darkText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: TextStyle(
                color: AppColors.darkText,
                fontFamily: appFont,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final menuBgColor =
        isDark ? AppColors.darkInputFill : AppColors.lightSurface;
    final iconBgColor =
        isDark ? AppColors.darkInputFill : AppColors.lightInputFill;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final hasNote = expense.note != null && expense.note!.trim().isNotEmpty;

    // Show note as the main title if it exists; otherwise fallback to category name (e.g., "Food")
    final titleText = hasNote ? expense.note!.trim() : expense.categoryName;

    // Show formatted date on HomePage, or the category name on HistoryPage
    final subtitleText = showCard
        ? '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}'
        : expense.categoryName;

    final tile = ListTile(
      contentPadding: showCard
          ? const EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 4)
          : EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          expense.categoryIcon,
          style: const TextStyle(fontSize: 22),
        ),
      ),
      title: Text(
        titleText,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: appFont,
        ),
      ),
      subtitle: Text(
        subtitleText,
        style: TextStyle(color: textSecondary, fontFamily: appFont),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${expense.amount.toStringAsFixed(0)} EGP',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? AppColors.accentCyan : AppColors.primaryBlue,
              fontFamily: appFont,
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: textSecondary,
            ),
            color: menuBgColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                _openEditExpenseOverlay(context, surfaceColor);
              } else if (value == 'delete') {
                _confirmAndDelete(
                    context, surfaceColor, textColor, textSecondary);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color: isDark ? AppColors.accentCyan : AppColors.primaryTeal,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Edit',
                      style: TextStyle(
                        color: textColor,
                        fontFamily: appFont,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_outline,
                      color: AppColors.errorRed,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: AppColors.errorRed,
                        fontFamily: appFont,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (showCard) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: tile,
      );
    }

    return tile;
  }
}