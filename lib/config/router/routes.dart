abstract class Routes {
  static const String home = '/home/:page';
  static const String accountForm = '/account/form/:id';

  static String accountFormPage(String id) => accountForm.replaceAll(':id', id);
  static String changeViewPage(int page) => home.replaceAll(':page', '$page');
}
