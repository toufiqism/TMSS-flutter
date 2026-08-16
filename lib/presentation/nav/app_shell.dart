import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_result.dart';
import '../../di/providers.dart';
import '../../theme/colors.dart';
import '../../theme/shapes.dart';
import '../../theme/typography.dart';
import '../common/safe_insets.dart';
import '../common/section_label.dart';
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

/// The chrome every signed-in screen sits in: hairline top bar and navigation drawer,
/// both restyled to the daylight design.
///
/// A ConsumerWidget (rather than taking userName as a param from the caller) so it can
/// watch session state and call logout directly, since go_router's ShellRoute builder
/// isn't itself a Consumer.
class AppShell extends ConsumerWidget {
  const AppShell({
    super.key,
    required this.currentPath,
    required this.onNavigate,
    required this.onOpenProfile,
    required this.child,
    this.topBarTitle,
  });

  final String currentPath;
  final ValueChanged<String> onNavigate;

  /// Pushed rather than navigated to, so the profile returns to the screen it was
  /// opened from instead of replacing it in the shell.
  final VoidCallback onOpenProfile;
  final Widget child;

  /// Replaces the logo + wordmark on screens that name themselves.
  final Widget? topBarTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionStreamProvider);
    final user = sessionAsync.value?.user;
    final initials = user == null ? '' : _initialsOf(user.name);

    return Scaffold(
      backgroundColor: tracGoPageBackground,
      drawerScrimColor: tracGoScrim,
      drawer: _AppDrawer(
        currentPath: currentPath,
        onNavigate: onNavigate,
        onOpenProfile: onOpenProfile,
      ),
      appBar: AppBar(
        titleSpacing: 0,
        leadingWidth: 52,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const _MenuGlyph(),
            tooltip: TracGoStrings.navOpenMenu,
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title:
            topBarTitle ??
            Row(
              children: [
                const TracGoLogoMark(size: 30),
                const SizedBox(width: 10),
                // Flexible so a large text scale wraps the wordmark instead of pushing
                // the avatar off the bar.
                Flexible(
                  child: Text(
                    TracGoStrings.appName,
                    style: tracGoTextTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: TracGoStrings.navProfile,
              onPressed: onOpenProfile,
              // The avatar replaced the old person icon *and* the notification bell.
              // The bell was wired to an empty callback with a permanent "0" badge —
              // chrome that promised a feature the app does not have.
              icon: _InitialsAvatar(
                initials: initials,
                size: 34,
                background: tracGoSurfaceSoft,
                foreground: tracGoGreen,
                fontSize: 12,
                fallbackIcon: Icons.person_outline,
              ),
            ),
          ),
        ],
      ),
      // Back handling deliberately does *not* live here. It is mounted inside the
      // shell's nested navigator, around each screen, because that is the navigator
      // predictive back consults — see `DashboardBackScope`.
      body: child,
    );
  }
}

/// The design's three-rule menu glyph: two full-width bars in ink and a short lime one.
///
/// Drawn rather than using `Icons.menu` because the lime third rule is the one place the
/// accent colour appears on an otherwise white top bar, and Material's glyph has no
/// per-bar colour.
class _MenuGlyph extends StatelessWidget {
  const _MenuGlyph();

  @override
  Widget build(BuildContext context) {
    // Fixed size, not text-scaled: this is an icon, and scaling it to 3x would blow out
    // the top bar's height on both platforms.
    return SizedBox(
      width: 20,
      height: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _bar(20, tracGoInk),
          _bar(20, tracGoInk),
          _bar(13, tracGoLime),
        ],
      ),
    );
  }

  Widget _bar(double width, Color color) => Container(
    width: width,
    height: 2,
    decoration: BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.all(Radius.circular(2)),
    ),
  );
}

/// A round initials badge. Falls back to an icon while the session has not resolved, so
/// the top bar never shows an empty circle on the first frame.
class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({
    required this.initials,
    required this.size,
    required this.background,
    required this.foreground,
    required this.fontSize,
    this.fallbackIcon,
  });

  final String initials;
  final double size;
  final Color background;
  final Color foreground;
  final double fontSize;
  final IconData? fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: initials.isEmpty && fallbackIcon != null
          ? Icon(fallbackIcon, size: size * 0.55, color: foreground)
          // The circle is a fixed size, so its contents cannot be allowed to scale past
          // it; the name it abbreviates is on screen in full in the drawer regardless.
          : MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.0,
              child: Text(
                initials,
                style: tracGoTextTheme.titleMedium?.copyWith(
                  fontSize: fontSize,
                  color: foreground,
                ),
              ),
            ),
    );
  }
}

class _AppDrawer extends ConsumerWidget {
  const _AppDrawer({
    required this.currentPath,
    required this.onNavigate,
    required this.onOpenProfile,
  });

  final String currentPath;
  final ValueChanged<String> onNavigate;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionStreamProvider).value?.user;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      backgroundColor: tracGoSurfaceWhite,
      // Square inner edge, per the design: the drawer is a panel, not a floating card.
      shape: const RoundedRectangleBorder(),
      // Scrollable, with the logout row still pinned to the bottom. At large
      // accessibility text sizes the header, nav items and logout together exceed the
      // drawer's height and the Column overflowed by ~183px, clipping logout off the
      // bottom entirely. IntrinsicHeight gives the Column a bounded height so the
      // Spacer still resolves; the ConstrainedBox keeps it filling the drawer when
      // the content is shorter than the viewport.
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DrawerHeader(
                    name: user?.name,
                    designation: user?.designation,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 18, 14, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(12, 6, 12, 10),
                          child: SectionLabel(
                            TracGoStrings.navMenuSectionLabel,
                          ),
                        ),
                        _DrawerItem(
                          label: TracGoStrings.navDashboard,
                          selected: currentPath == RoutePaths.dashboard,
                          onTap: () {
                            Navigator.of(context).pop();
                            onNavigate(RoutePaths.dashboard);
                          },
                        ),
                        _DrawerItem(
                          label: TracGoStrings.navMyRequisition,
                          selected: currentPath == RoutePaths.requisitionList,
                          onTap: () {
                            Navigator.of(context).pop();
                            onNavigate(RoutePaths.requisitionList);
                          },
                        ),
                        _DrawerItem(
                          label: TracGoStrings.navProfile,
                          // Profile is pushed above the shell rather than being one of
                          // its destinations, so `currentPath` never equals it and the
                          // row is never the selected one.
                          selected: false,
                          onTap: () {
                            Navigator.of(context).pop();
                            onOpenProfile();
                          },
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Divider(height: 1, color: tracGoBorder),
                  Padding(
                    // The drawer is edge-to-edge, so the footer would otherwise sit
                    // under Android's gesture bar and iOS's home indicator — the one
                    // row here that has nothing scrollable beneath it to absorb them.
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      10,
                      20,
                      20,
                    ).addBottomSystemInset(context),
                    child: Row(
                      children: [
                        const Expanded(child: _LogoutDrawerAction()),
                        Text(
                          TracGoStrings.appVersionLabel,
                          style: tracGoTextTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: tracGoPlaceholder,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Navy header block with a lime glow bleeding in from the top-right corner.
class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.name, required this.designation});

  final String? name;
  final String? designation;

  @override
  Widget build(BuildContext context) {
    final resolvedName = name;

    return ClipRect(
      child: Container(
        width: double.infinity,
        color: tracGoInk,
        child: Stack(
          children: [
            // Decorative only; deliberately outside the SafeArea padding below so it
            // bleeds under the status bar the way the design shows it.
            Positioned(
              right: -60,
              top: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x477AB648), Color(0x0012122B)],
                    stops: [0.0, 0.7],
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mono: this sits on navy, where the colour art's own navy road
                    // disappears into the background.
                    const TracGoLogoMark(
                      size: 40,
                      variant: TracGoLogoVariant.mono,
                    ),
                    if (resolvedName != null) ...[
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          _InitialsAvatar(
                            initials: _initialsOf(resolvedName),
                            size: 50,
                            background: tracGoLime,
                            foreground: tracGoInk,
                            fontSize: 17,
                          ),
                          const SizedBox(width: 13),
                          // Expanded so a long name wraps inside the drawer rather than
                          // overflowing it at large accessibility text sizes.
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  resolvedName,
                                  style: tracGoTextTheme.titleMedium?.copyWith(
                                    fontSize: 17,
                                    color: tracGoSurfaceWhite,
                                  ),
                                ),
                                if (designation != null &&
                                    designation!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    designation!,
                                    style: tracGoTextTheme.bodySmall?.copyWith(
                                      color: tracGoSurfaceWhite.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The drawer's Log Out control.
///
/// A widget of its own so it can watch [logoutNotifierProvider] without rebuilding the
/// whole shell, and so the in-flight guard lives in one place. It disables itself while
/// a sign-out is running: the drawer closes on tap, so without the guard a user who
/// reopened it could fire a second `POST /logout` with a token the first call had
/// already revoked.
class _LogoutDrawerAction extends ConsumerWidget {
  const _LogoutDrawerAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggingOut = ref.watch(logoutNotifierProvider);

    return InkWell(
      borderRadius: pillBorderRadius,
      onTap: isLoggingOut
          ? null
          : () async {
              // Both captured before the drawer closes and before the await: this
              // widget is disposed by the pop, so `context` is unusable afterwards,
              // while the messenger it resolves to lives above the drawer and survives
              // the redirect to Login.
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop();

              final result = await ref
                  .read(logoutNotifierProvider.notifier)
                  .logout();

              // null means a sign-out was already in flight — not a failure, and not
              // something to report twice.
              if (result == null || result is ApiSuccess<void>) return;
              messenger.showSnackBar(
                const SnackBar(
                  content: Text(TracGoStrings.navLogoutRevokeFailed),
                ),
              );
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Flexible(
              child: Text(
                isLoggingOut
                    ? TracGoStrings.navLoggingOut
                    : TracGoStrings.navLogout,
                style: tracGoTextTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tracGoDestructiveRed,
                ),
              ),
            ),
            if (isLoggingOut) ...[
              const SizedBox(width: 10),
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: tracGoDestructiveRed,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A drawer navigation row: dot indicator, then the label. No icons — the design
/// replaced them with the dot, which is what carries the selected state.
class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: tracGoBorderRadius(tracGoRadiusSmall),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? tracGoSurfaceSoft : Colors.transparent,
            borderRadius: tracGoBorderRadius(tracGoRadiusSmall),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: selected ? tracGoGreen : tracGoDashedAccentBorder,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // Expanded so the label wraps inside the drawer rather than overflowing
              // it at large accessibility text sizes.
              Expanded(
                child: Text(
                  label,
                  style: tracGoTextTheme.bodyLarge?.copyWith(
                    color: selected ? tracGoInk : tracGoTextBody,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
