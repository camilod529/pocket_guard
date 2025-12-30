import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_guard/domain/entities/localized_language.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/settings_providers.dart';

List<LocalizedLanguage> _getLocalizedLanguages(AppLocalizations localizations) {
  return [
    LocalizedLanguage(
      code: 'en',
      displayName: localizations.english,
      nativeName: localizations.englishNative,
    ),
    LocalizedLanguage(
      code: 'es',
      displayName: localizations.spanish,
      nativeName: localizations.spanishNative,
    ),
    LocalizedLanguage(
      code: 'fr',
      displayName: localizations.french,
      nativeName: localizations.frenchNative,
    ),
  ];
}

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final localeAsync = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settings), centerTitle: true),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.selectAppLanguage,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final lang = _getLocalizedLanguages(localizations)[index];
                  final isSelected = localeAsync.when(
                    data: (currentLocale) => currentLocale == lang.code,
                    loading: () => false,
                    error: (_, _) => false,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => ref
                            .read(localeProvider.notifier)
                            .setLocale(lang.code),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected
                                ? Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    width: 2,
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant.withAlpha(128),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                child: Text(
                                  lang.code.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang.displayName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      lang.nativeName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, size: 28)
                              else
                                Icon(
                                  Icons.circle_outlined,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  size: 28,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: _getLocalizedLanguages(
                  AppLocalizations.of(context)!,
                ).length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
