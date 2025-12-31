import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ui_visibility_provider.g.dart';

@riverpod
class FilterSheetVisibility extends _$FilterSheetVisibility {
  @override
  bool build() => false; // false = hidden, true = visible

  void hide() => state = false;
  void show() => state = true;
}
