
enum ExpenseCategory { food, transport, bills, shopping, fun, other }

class Expense {
  final String id;
  final double amount;
  final ExpenseCategory category;
  final String? note;
  final DateTime date;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    this.note,
    required this.date,
  });

  // Helper to get the correct icon/emoji based on category
  String get categoryIcon {
    switch (category) {
      case ExpenseCategory.food: return '🍔';
      case ExpenseCategory.transport: return '🚌';
      case ExpenseCategory.bills: return '🧾';
      case ExpenseCategory.shopping: return '🛍️';
      case ExpenseCategory.fun: return '🎬';
      case ExpenseCategory.other: return '❇️';
    }
  }

  // Helper to get formatted category name
  String get categoryName {
    final name = category.toString().split('.').last;
    return name[0].toUpperCase() + name.substring(1);
  }
}