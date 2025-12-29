import 'package:flutter/material.dart';
import 'package:pocket_guard/presentation/views/account_view.dart';
import 'package:pocket_guard/presentation/views/calendar_view.dart';
import 'package:pocket_guard/presentation/views/more_view.dart';
import 'package:pocket_guard/presentation/widgets/shared/custom_bottom_navigation_bar.dart';

class HomeScreen extends StatelessWidget {
  static const name = 'home_screen';
  final int pageIndex;

  final viewRoutes = const [CalendarView(), AccountView(), MoreView()];

  const HomeScreen({super.key, required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: pageIndex, children: viewRoutes),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: pageIndex),
    );
  }
}
