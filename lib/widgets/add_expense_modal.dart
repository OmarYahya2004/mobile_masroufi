import 'package:flutter/material.dart';
import '../data/models/expense.dart';
import '../data/remote/firebase_service.dart';

class AddExpenseModal extends StatefulWidget {
  final void Function(Expense expense) onAddExpense;

  const AddExpenseModal({super.key, required this.onAddExpense});

  @override
  State<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  
  DateTime _selectedDate = DateTime.now(); 

  // Helper for category icons matching the design
  String _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food: return '🍔';
      case ExpenseCategory.transport: return '🚌';
      case ExpenseCategory.bills: return '🧾';
      case ExpenseCategory.shopping: return '🛍️';
      // Make sure 'fun' and 'other' exist in your ExpenseCategory enum
      case ExpenseCategory.fun: return '🎬';
      case ExpenseCategory.other: return '✳️';
      default: return '📦'; 
    }
  }

  // Helper to capitalize category names
  String _getCategoryName(ExpenseCategory category) {
    final name = category.name;
    return name[0].toUpperCase() + name.substring(1);
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
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

  void _submitData() async {
    final enteredAmount = double.tryParse(_amountController.text);
    if (enteredAmount == null || enteredAmount <= 0) return;

    final newExpense = Expense(
      id: DateTime.now().toString(), 
      amount: enteredAmount,
      category: _selectedCategory,
      note: _noteController.text,
      date: _selectedDate,
    );

    widget.onAddExpense(newExpense);

    final dbService = FirebaseService();
    await dbService.addExpense(newExpense);

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
    final theme = Theme.of(context);
    final secondaryTextColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final inputFillColor = theme.colorScheme.surfaceContainerHighest; 

    final formattedDate = '${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.year}';

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
            Text('Add expense', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 16),
            
            // 1. Amount Field
            Text('Amount (EGP)', style: TextStyle(color: secondaryTextColor, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: secondaryTextColor),
                filled: true,
                fillColor: inputFillColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            
            // 2. Category Selection (Updated to 3-column Grid)
            Text('Category', style: TextStyle(color: secondaryTextColor, fontSize: 12)),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true, // Needed inside a Column/SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(), // Disables grid scrolling so parent handles it
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 columns
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15, // Creates the slightly wide rectangular look
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
                      color: inputFillColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_getCategoryIcon(category), style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 8),
                        Text(
                          _getCategoryName(category),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 12,
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
            Text('Note (optional)', style: TextStyle(color: secondaryTextColor, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              keyboardType: TextInputType.text,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'e.g. Uber to campus',
                hintStyle: TextStyle(color: secondaryTextColor),
                filled: true,
                fillColor: inputFillColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            
            // 4. Date Picker Field
            Text('Date', style: TextStyle(color: secondaryTextColor, fontSize: 12)),
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
                      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
                    ),
                    Icon(Icons.calendar_today, color: theme.colorScheme.onSurface, size: 20),
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
                      side: BorderSide(color: secondaryTextColor),
                    ),
                    child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save expense', style: TextStyle(fontWeight: FontWeight.bold)),
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