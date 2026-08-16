import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_result.dart';
import '../../di/providers.dart';
import '../../theme/colors.dart';
import '../../theme/shapes.dart';
import '../../theme/typography.dart';
import '../common/strings.dart';
import '../common/tracgo_logo_mark.dart';
import 'logout_notifier.dart';
import 'route_paths.dart';

const _honorifics = {
  'md',
  'md.',
  'mr',
  'mr.',
  'mrs',
  'mrs.',
  'ms',
  'ms.',
  'dr',
  'dr.',
};

String _initialsOf(String name) {
  final words = name
      .split(' ')
      .where((w) => w.isNotEmpty && !_honorifics.contains(w.toLowerCase()));
  return words.take(2).map((w) => w[0].toUpperCase()).join();
}

/// Ports AppShell.kt's drawer + top bar 1:1. A ConsumerWidget (rather than taking userName as a
/// param from the caller) so it can watch session state and call logout directly, since go_router's
/// ShellRoute builder isn't itself a Consumer.
class AppShell extends ConsumerWidget {
  const AppShell({
    super.key,
    required this.currentPath,
    required this.onNavigate,
    required this.onOpenProfile,
    required this.child,
    this.topBarTitle,
    this.showNotificationBell = true,
  });

  final String currentPath;
  final ValueChanged<String> onNavigate;

  /// Pushed rather than navigated to, so the profile returns to the screen it was
  /// opened from instead of replacing it in the shell.
  final VoidCallback onOpenProfile;
  final Widget child;
  final Widget? topBarTitle;
  final bool showNotificationBell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionStreamProvider);
    final user = sessionAsync.value?.user;

    return Scaffold(
      backgroundColor: tracGoPageBackground,
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.82,
        backgroundColor: tracGoSurfaceWhite,
        // Scrollable, with the logout row still pinned to the bottom. At large
        // accessibility text sizes the header, nav items and logout together exceed the
        // drawer's height and the Column overflowed by ~183px, clipping logout off the
        // bottom entirely. IntrinsicHeight gives the Column a bounded height so the
        // Spacer still resolves; the ConstrainedBox keeps it filling the drawer when
        // the content is shorter than the viewport.
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [tracGoGreenDark, tracGoGreen],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TracGoLogoMark(
                              badgeColor: Color(0x24FFFFFF),
                              glyphColor: tracGoLoginAccentGreen,
                              size: 26,
                              cornerRadius: 8,
                            ),
                            if (user != null) ...[
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: const BoxDecoration(
                                      color: tracGoGreenLight,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _initialsOf(user.name),
                                      style: tracGoTextTheme.titleMedium?.copyWith(
                                        color: tracGoGreen,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name,
                                          style: tracGoTextTheme.titleMedium
                                              ?.copyWith(
                                                color: tracGoSurfaceWhite,
                                              ),
                                        ),
                                        Text(
                                          user.designation,
                                          style: tracGoTextTheme.bodySmall
                                              ?.copyWith(
                                                color: tracGoSurfaceWhite
                                                    .withValues(alpha: 0.7),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _DrawerItem(
                              icon: Icons.dashboard_outlined,
                              label: TracGoStrings.navDashboard,
                              selected: currentPath == RoutePaths.dashboard,
                              onTap: () {
                                Navigator.of(context).pop();
                                onNavigate(RoutePaths.dashboard);
                              },
                            ),
                            _DrawerItem(
                              icon: Icons.assignment_outlined,
                              label: TracGoStrings.navMyRequisition,
                              selected:
                                  currentPath == RoutePaths.requisitionList,
                              onTap: () {
                                Navigator.of(context).pop();
                                onNavigate(RoutePaths.requisitionList);
                              },
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Divider(height: 1, color: tracGoDivider),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _LogoutDrawerItem(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: tracGoTextDark),
            tooltip: TracGoStrings.navOpenMenu,
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title:
            topBarTitle ??
            Row(
              children: [
                const TracGoLogoMark(
                  badgeColor: tracGoGreenLight,
                  glyphColor: tracGoGreen,
                  size: 24,
                  cornerRadius: 7,
                ),
                const SizedBox(width: 7),
                Text(TracGoStrings.appName, style: tracGoTextTheme.titleMedium),
              ],
            ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: tracGoTextMutedAlt),
            tooltip: TracGoStrings.navProfile,
            onPressed: onOpenProfile,
          ),
          if (showNotificationBell)
            IconButton(
              tooltip: TracGoStrings.navNotifications,
              onPressed: () {},
              icon: Badge(
                backgroundColor: tracGoDestructiveRed,
                label: const Text('0'),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: tracGoTextMutedAlt,
                ),
              ),
            ),
        ],
      ),
      body: child,
    );
  }
}

/// The drawer's Log Out row.
///
/// A widget of its own so it can watch [logoutNotifierProvider] without rebuilding the
/// whole shell, and so the in-flight guard lives in one place. The row disables itself
/// while a sign-out is running: the drawer closes on tap, so without the guard a user
/// who reopened it could fire a second `POST /logout` with a token the first call had
/// already revoked.
class _LogoutDrawerItem extends ConsumerWidget {
  const _LogoutDrawerItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggingOut = ref.watch(logoutNotifierProvider);

    return _DrawerItem(
      icon: Icons.logout,
      label: isLoggingOut ? TracGoStrings.navLoggingOut : TracGoStrings.navLogout,
      selected: false,
      tint: tracGoDestructiveRed,
      trailing: isLoggingOut
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: tracGoDestructiveRed,
              ),
            )
          : null,
      onTap: isLoggingOut
          ? null
          : () async {
              // Both captured before the drawer closes and before the await: this
              // widget is disposed by the pop, so `context` is unusable afterwards,
              // while the messenger it resolves to lives above the drawer and survives
              // the redirect to Login.
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop();

              final result = await ref.read(logoutNotifierProvider.notifier).logout();

              // null means a sign-out was already in flight — not a failure, and not
              // something to report twice.
              if (result == null || result is ApiSuccess<void>) return;
              messenger.showSnackBar(
                const SnackBar(content: Text(TracGoStrings.navLogoutRevokeFailed)),
              );
            },
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.tint,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final bool selected;

  /// Null disables the row — used while a sign-out is in flight.
  final VoidCallback? onTap;
  final Color? tint;

  /// Optional adornment at the end of the row, such as a progress spinner.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final effectiveTint = tint ?? (selected ? tracGoGreen : tracGoTextMutedAlt);
    return InkWell(
      onTap: onTap,
      borderRadius: pillBorderRadius,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? tracGoGreenLight : Colors.transparent,
          borderRadius: pillBorderRadius,
        ),
        child: Row(
          children: [
            Icon(icon, color: effectiveTint, size: 19),
            const SizedBox(width: 14),
            // Expanded so the label wraps inside the drawer rather than overflowing it
            // at large accessibility text sizes.
            Expanded(
              child: Text(
                label,
                style: tracGoTextTheme.bodyLarge?.copyWith(
                  color: selected ? tracGoTextDark : effectiveTint,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14.5,
                ),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ],
        ),
      ),
    );
  }
}
