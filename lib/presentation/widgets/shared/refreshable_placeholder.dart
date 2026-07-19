import 'package:flutter/material.dart';

/// Wraps non-list content (loading spinners, empty/error states) so it
/// still centers like a plain [Center], but stays technically scrollable -
/// needed wherever this sits inside a [RefreshIndicator], since it only
/// recognizes a pull gesture if its child subtree contains an actual
/// [Scrollable]. Without this, pulling to refresh would silently do
/// nothing whenever a screen is showing its loading/empty/error state
/// instead of a real list.
class RefreshablePlaceholder extends StatelessWidget {
  final Widget child;

  const RefreshablePlaceholder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [SliverFillRemaining(child: Center(child: child))],
    );
  }
}
