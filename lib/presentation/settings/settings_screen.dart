import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/state_views.dart';
import '../providers/cycle_provider.dart';
import '../providers/view_state.dart';
import '../splash/splash_screen.dart';

/// Settings tab: profile summary, premium upsell, account/support
/// options, and logout.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CycleProvider>(
      builder: (context, provider, _) {
        switch (provider.state) {
          case ViewState.initial:
          case ViewState.loading:
            return const LoadingView();
          case ViewState.error:
            return ErrorView(
              message: provider.errorMessage ?? 'Something went wrong.',
              onRetry: provider.loadInitialData,
            );
          case ViewState.empty:
            return const EmptyView(message: 'No profile data available.');
          case ViewState.loaded:
            final user = provider.userProfile;
            if (user == null) {
              return const EmptyView(message: 'No profile data available.');
            }
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.pagePadding(context),
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.surfaceCard,
                          child: Icon(Icons.person_outline,
                              size: 40, color: AppColors.deepRose),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(user.name, style: AppTextStyles.h1),
                        const SizedBox(height: AppSpacing.xs),
                        Text(user.email, style: AppTextStyles.bodyMuted),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (!user.isPremium) _PremiumBanner(),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Account Settings', style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.sm),
                  _SettingsGroup(
                    items: const [
                      _SettingsItemData(
                          icon: Icons.people_outline, label: 'Edit Profile'),
                      _SettingsItemData(
                          icon: Icons.fingerprint,
                          label: 'Change Password'),
                      _SettingsItemData(
                          icon: Icons.lock_outline, label: 'Privacy Policy'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Support & Info', style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.sm),
                  _SettingsGroup(
                    items: const [
                      _SettingsItemData(
                          icon: Icons.help_outline, label: 'Help Center'),
                      _SettingsItemData(
                          icon: Icons.info_outline, label: 'About Moodly'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  OutlinedButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surfaceCardLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            );
        }
      },
    );
  }

  void _logout(BuildContext context) {
    // For this build, "logout" simply returns to the splash flow.
    // A real backend integration would clear auth tokens here first.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
          (route) => false,
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Unlock Calm Premium', style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Get personalized insights and advanced cycle tracking.',
                  style: AppTextStyles.bodyMuted,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}

class _SettingsItemData {
  const _SettingsItemData({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.items});

  final List<_SettingsItemData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: AppColors.deepRose),
                title: Text(item.label, style: AppTextStyles.bodyLarge),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.deepRose),
                onTap: () {},
              ),
              if (index != items.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }
}
