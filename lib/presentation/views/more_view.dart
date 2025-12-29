import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager_flutter/config/theme/app_theme.dart';
import 'package:money_manager_flutter/l10n/app_localizations.dart';
import 'package:money_manager_flutter/presentation/providers/settings_providers.dart';

class MoreView extends ConsumerWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final themeIndexAsync = ref.watch(themeIndexProvider);
    final localeAsync = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.more), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Section
          _buildSectionTitle(context, localizations.theme),
          if (themeIndexAsync.isLoading)
            _buildLoadingTile()
          else
            ..._buildColorOptions(ref, themeIndexAsync),
          const SizedBox(height: 24),

          // Language Section
          _buildSectionTitle(context, localizations.language),
          if (localeAsync.isLoading)
            _buildLoadingTile()
          else
            ..._buildLanguageOptions(ref, localeAsync),
        ],
      ),
    );
  }

  List<Widget> _buildColorOptions(
    WidgetRef ref,
    AsyncValue<int> themeIndexAsync,
  ) {
    return appColors.asMap().entries.map((entry) {
      final index = entry.key;
      final color = entry.value;
      final isSelected = themeIndexAsync.when(
        data: (selected) => selected == index,
        loading: () => false,
        error: (_, _) => false,
      );

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () =>
                ref.read(themeIndexProvider.notifier).setThemeIndex(index),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withAlpha(77),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Text(_getColorName(index))),
                  if (isSelected)
                    Icon(Icons.check_circle, color: color, size: 24),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildLanguageOptions(
    WidgetRef ref,
    AsyncValue<String> localeAsync,
  ) {
    final languages = [
      {'code': 'es', 'name': 'Español'},
      {'code': 'en', 'name': 'English'},
    ];

    return languages.map((lang) {
      final isSelected = localeAsync.when(
        data: (current) => current == lang['code'],
        loading: () => false,
        error: (_, _) => false,
      );

      return SwitchListTile.adaptive(
        title: Text(lang['name']!),
        subtitle: Text(lang['code']!),
        value: isSelected,
        onChanged: (value) {
          if (value) {
            ref.read(localeProvider.notifier).setLocale(lang['code']!);
          }
        },
        secondary: CircleAvatar(
          backgroundColor: Theme.of(ref.context).colorScheme.primary,
          child: Text(
            lang['code']!.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );
    }).toList();
  }

  Widget _buildLoadingTile() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text('Loading...'),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  String _getColorName(int index) {
    final names = [
      'Indigo',
      'Deep Purple',
      'Blue',
      'Purple',
      'Yellow',
      'Cyan',
      'Teal',
      'Lime',
    ];
    return names[index];
  }
}
