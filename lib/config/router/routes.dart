abstract class Routes {
  static const String home = '/home/:page';

  static String changeViewPage(int page) => home.replaceAll(':page', '$page');
}
