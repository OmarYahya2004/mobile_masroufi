import '../../data/models/expense.dart';

class AppConstants {
  static const String appFont = 'Poppins';

  // Helper for category icons matching the design
  static String getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return '🍔';
      case ExpenseCategory.transport:
        return '🚌';
      case ExpenseCategory.bills:
        return '🧾';
      case ExpenseCategory.shopping:
        return '🛍️';
      case ExpenseCategory.fun:
        return '🎬';
      case ExpenseCategory.other:
        return '📦';
      default:
        return '✳️';
    }
  }

  // Helper to capitalize category names
  static String getCategoryName(ExpenseCategory category) {
    final name = category.name;
    return name[0].toUpperCase() + name.substring(1);
  }
}