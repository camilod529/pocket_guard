import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/presentation/widgets/recurring_transactions/date_row.dart';

void main() {
  Future<int> tapsAfterTapping(WidgetTester tester, Finder target) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DateRow(
            label: 'Target date',
            date: null,
            noneLabel: 'None',
            onTap: () => taps++,
          ),
        ),
      ),
    );
    await tester.tap(target);
    return taps;
  }

  testWidgets('tapping the label opens the picker', (tester) async {
    expect(await tapsAfterTapping(tester, find.text('Target date')), 1);
  });

  testWidgets('tapping the date box opens the picker', (tester) async {
    expect(await tapsAfterTapping(tester, find.text('None')), 1);
  });
}
