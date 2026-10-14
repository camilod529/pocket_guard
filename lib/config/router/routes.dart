abstract class Routes {
  // --- Shell Routes (Tabs) ---
  static const String calendar = '/calendar';
  static const String accounts = '/accounts';
  static const String categories = '/categories';
  static const String more = '/more';

  // --- Root Routes (Full Screen / No Bottom Nav) ---
  // Note: These start with / so they are absolute top-level paths
  static const String transactionForm = '/transaction/form/:id';
  static const String accountForm = '/account/form/:id';
  static const String categoryForm = '/category/form/:id';
  static const String insights = '/insights';
  static const String recurringTransactions = '/recurring-transactions';
  static const String recurringTransactionForm =
      '/recurring-transaction/form/:id';
  static const String budgets = '/budgets';
  static const String budgetForm = '/budget/form/:id';
  static const String goals = '/goals';
  static const String goalDetail = '/goal/:id';
  static const String savingsGoalForm = '/goal/form/:id';
  static const String wishlist = '/wishlist';
  static const String wishlistForm = '/wishlist/form/:id';

  // Settings
  static const String themeSettings = '/settings/theme';
  static const String languageSettings = '/settings/language';

  // --- Helper Methods ---
  static String accountFormPage(String id) => accountForm.replaceAll(':id', id);
  static String categoryFormPage(String id) =>
      categoryForm.replaceAll(':id', id);
  static String transactionFormPage(String id) =>
      transactionForm.replaceAll(':id', id);
  static String recurringTransactionFormPage(String id) =>
      recurringTransactionForm.replaceAll(':id', id);
  static String budgetFormPage(String id) =>
      budgetForm.replaceAll(':id', id);
  static String goalDetailPage(String id) => goalDetail.replaceAll(':id', id);
  static String savingsGoalFormPage(String id) =>
      savingsGoalForm.replaceAll(':id', id);
  static String wishlistFormPage(String id) =>
      wishlistForm.replaceAll(':id', id);
}
