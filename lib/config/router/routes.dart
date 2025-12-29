abstract class Routes {
  static const String home = '/home/:page';
  static const String accountForm = '/account/form/:id';
  static const String transactionForm = '/transaction/form/:id';

  // Settings routes
  static const String more = '/more';
  static const String themeSettings = '/more/theme';
  static const String languageSettings = '/more/language';
  static const String notificationsSettings = '/more/notifications';
  static const String securitySettings = '/more/security';
  static const String dataExportSettings = '/more/data';
  static const String helpSupportSettings = '/more/help';

  static String accountFormPage(String id) => accountForm.replaceAll(':id', id);
  static String changeViewPage(int page) => home.replaceAll(':page', '$page');
  static String transactionFormPage(String id) =>
      transactionForm.replaceAll(':id', id);
}
