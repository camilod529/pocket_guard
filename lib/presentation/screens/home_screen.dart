import 'package:flutter/material.dart';
import 'package:money_manager_flutter/presentation/views/calendar_view.dart';
import 'package:money_manager_flutter/presentation/views/more_view.dart';
import 'package:money_manager_flutter/presentation/widgets/shared/custom_bottom_navigation_bar.dart';

class HomeScreen extends StatelessWidget {
  static const name = 'home_screen';
  final int pageIndex;

  final viewRoutes = const [CalendarView(), MoreView()];

  const HomeScreen({super.key, required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: pageIndex, children: viewRoutes),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: pageIndex),
    );
  }
}
