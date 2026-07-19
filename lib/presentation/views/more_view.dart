// lib/presentation/screens/more_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/config/router/routes.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';

class MoreView extends ConsumerWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
        centerTitle: true,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSettingsCard(
                  context,
                  icon: Icons.palette_outlined,
                  title: localizations.theme,
                  subtitle: localizations.chooseYourAppColor,
                  route: Routes.themeSettings,
                  ref: ref,
                ),
                _buildSettingsCard(
                  context,
                  icon: Icons.language_outlined,
                  title: localizations.language,
                  subtitle: localizations.selectAppLanguage,
                  route: Routes.languageSettings,
                  ref: ref,
                ),
                _buildSettingsCard(
                  context,
                  icon: Icons.autorenew,
                  title: localizations.recurringTransactions,
                  subtitle: localizations.manageRecurringTransactions,
                  route: Routes.recurringTransactions,
                  ref: ref,
                ),
                // _buildSettingsCard(
                //   context,
                //   icon: Icons.notifications_outlined,
                //   title: localizations.notifications ?? 'Notifications',
                //   subtitle:
                //       localizations.manageNotifications ??
                //       'Manage notifications',
                //   route: Routes.notificationsSettings,
                //   ref: ref,
                // ),
                // _buildSettingsCard(
                //   context,
                //   icon: Icons.security_outlined,
                //   title: localizations.security ?? 'Security',
                //   subtitle:
                //       localizations.protectYourData ?? 'Protect your data',
                //   route: Routes.securitySettings,
                //   ref: ref,
                // ),
                // _buildSettingsCard(
                //   context,
                //   icon: Icons.data_usage_outlined,
                //   title: localizations.dataExport ?? 'Data & Export',
                //   subtitle: localizations.backupYourData ?? 'Backup your data',
                //   route: Routes.dataExportSettings,
                //   ref: ref,
                // ),
                // _buildSettingsCard(
                //   context,
                //   icon: Icons.help_outline,
                //   title: localizations.helpSupport ?? 'Help & Support',
                //   subtitle: localizations.getHelp ?? 'Get help and support',
                //   route: Routes.helpSupportSettings,
                //   ref: ref,
                // ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required WidgetRef ref,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest.withAlpha(179),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant.withAlpha(128)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(20),
        splashColor: colors.primary.withAlpha(26),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withAlpha(26),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(icon, color: colors.onPrimaryContainer, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
