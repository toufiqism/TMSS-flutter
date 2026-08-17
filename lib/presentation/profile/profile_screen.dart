import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/api_result.dart';
import '../../di/providers.dart';
import '../../domain/model/user.dart';
import '../../theme/colors.dart';
import '../../theme/motion.dart';
import '../../theme/shapes.dart';
import '../../theme/typography.dart';
import '../common/key_value_row.dart';
import '../common/motion.dart';
import '../common/safe_insets.dart';
import '../common/section_label.dart';
import '../common/skeleton.dart';
import '../common/strings.dart';
import '../common/surface_card.dart';
import '../nav/logout_notifier.dart';
import 'profile_notifier.dart';
import 'profile_state.dart';

final _dateFormatter = DateFormat('dd MMM yyyy');

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

/// Initials for the avatar, skipping honorifics so "Md. Tofiq Akbar" reads TA, not MT.
String _initialsOf(String name) {
  final words = name
      .split(' ')
      .where((w) => w.isNotEmpty && !_honorifics.contains(w.toLowerCase()));
  return words.take(2).map((w) => w[0].toUpperCase()).join();
}

/// Read-only profile.
///
/// Two sources, deliberately decoupled: identity comes from the stored session and is
/// on screen immediately, while the account block is fetched from `GET /user`. A failed
/// fetch degrades that block alone — it never blanks a page whose main content is
/// already known and correct.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  StreamSubscription<ProfileEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(profileNotifierProvider.notifier);
      _eventSub = notifier.events.listen((event) {
        if (!mounted) return;
        if (event is ProfileSessionExpired) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(event.message)));
        }
      });
      unawaited(notifier.load());
    });
  }

  @override
  void dispose() {
    unawaited(_eventSub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(profileNotifierProvider);
    final notifier = ref.read(profileNotifierProvider.notifier);
    // Identity comes straight from the session, watched here rather than copied into
    // notifier state: it is already on the device, renders on the first frame, and is
    // unaffected by whether the account fetch succeeds.
    final user = ref.watch(sessionStreamProvider).value?.user;
    final motion = TracGoMotion.of(context);

    return Scaffold(
      backgroundColor: tracGoPageBackground,
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text(
          TracGoStrings.profileTitle,
          style: tracGoScreenTitleStyle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: tracGoInk),
          onPressed: widget.onBack,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: notifier.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            24,
            20,
            24,
          ).addBottomSystemInset(context),
          children: [
            // Staggered by hand rather than through `staggerAll`, because the first two
            // blocks are conditional: the indexes have to keep counting from zero when
            // the session has no user to render.
            if (user != null) ...[
              FadeSlideIn(
                child: _Identity(
                  user: user,
                  activeStatus: uiState.account?.activeStatus,
                ),
              ),
              const SizedBox(height: 24),
              FadeSlideIn(
                delay: motion.staggerDelay(1),
                child: _Section(
                  title: TracGoStrings.profileSectionContact,
                  rows: [
                    KeyValueRow(
                      TracGoStrings.profileEmail,
                      user.email,
                      placeholder: TracGoStrings.profileNotProvided,
                    ),
                    KeyValueRow(
                      TracGoStrings.profilePhone,
                      user.phone,
                      placeholder: TracGoStrings.profileNotProvided,
                    ),
                    KeyValueRow(
                      TracGoStrings.profileCompany,
                      user.companyName,
                      placeholder: TracGoStrings.profileNotProvided,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            FadeSlideIn(
              delay: motion.staggerDelay(user != null ? 2 : 0),
              child: _AccountSection(
                state: uiState,
                onRetry: () => unawaited(notifier.load()),
              ),
            ),
            const SizedBox(height: 28),
            FadeSlideIn(
              delay: motion.staggerDelay(user != null ? 3 : 1),
              child: const _LogoutButton(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centred avatar, name and one-line role, per the design.
class _Identity extends StatelessWidget {
  const _Identity({required this.user, required this.activeStatus});

  final User user;

  /// From `GET /user`; null until it lands, and permanently if it fails. The dot and
  /// the word are dropped together in that case rather than showing a lone separator.
  final String? activeStatus;

  @override
  Widget build(BuildContext context) {
    final status = activeStatus?.trim() ?? '';
    final designation = user.designation.trim();

    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: const BoxDecoration(
            color: tracGoInk,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          // Fixed circle, so its contents cannot scale past it. The full name is
          // directly underneath at whatever size the user has chosen.
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.0,
            child: Text(
              _initialsOf(user.name),
              style: tracGoTextTheme.titleLarge?.copyWith(
                fontSize: 28,
                color: tracGoLime,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.name,
          textAlign: TextAlign.center,
          style: tracGoTextTheme.titleLarge,
        ),
        if (designation.isNotEmpty || status.isNotEmpty) ...[
          const SizedBox(height: 6),
          // Wrap, not Row: designation plus status overflows a phone width at large
          // accessibility text sizes.
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              if (designation.isNotEmpty)
                Text(
                  designation,
                  style: tracGoTextTheme.bodySmall?.copyWith(
                    color: tracGoTextMuted,
                  ),
                ),
              if (designation.isNotEmpty && status.isNotEmpty)
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: tracGoDashedAccentBorder,
                    shape: BoxShape.circle,
                  ),
                ),
              if (status.isNotEmpty)
                Text(
                  status,
                  style: tracGoTextTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: tracGoGreen,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.state, required this.onRetry});

  final ProfileUiState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Cross-fades between skeleton, error and content. `AnimatedSize` on top because the
    // three differ in height — four rows, a two-line error, sometimes two rows — and a
    // fade between differently-sized cards would otherwise snap the Log Out button below
    // it up or down the page mid-transition.
    return AnimatedSize(
      duration: TracGoMotion.of(context).base,
      curve: tracGoMotionCurve,
      alignment: Alignment.topCenter,
      child: MotionSwitcher(child: _card(context)),
    );
  }

  Widget _card(BuildContext context) {
    // Identity above is already on screen from the stored session, so only this block is
    // ever waiting — a skeleton of exactly the four rows `GET /user` fills in, rather
    // than a spinner in a card whose height then changes when the data lands.
    if (state.isLoading) {
      return SkeletonSemantics(
        key: const ValueKey('loading'),
        label: TracGoStrings.loadingProfile,
        child: SkeletonHost(
          child: _Section(
            title: TracGoStrings.profileSectionAccount,
            rows: [
              // 13px vertical, matching `KeyValueRow` exactly — the card is already
              // padded 16/6 by `_Section`, so the rows only supply their own inset.
              for (var i = 0; i < 4; i++)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBox(width: 104, height: 14, radius: 6),
                      SkeletonBox(width: 88, height: 14, radius: 6),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    final error = state.errorMessage;
    if (error != null) {
      return _Section(
        key: const ValueKey('error'),
        title: TracGoStrings.profileSectionAccount,
        rows: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TracGoStrings.profileAccountUnavailable,
                  style: tracGoTextTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error,
                  style: tracGoTextTheme.bodySmall?.copyWith(
                    color: tracGoTextMutedAlt,
                  ),
                ),
                // Withheld for terminal failures such as 403, where a second attempt
                // cannot produce a different answer.
                if (state.canRetry) ...[
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: onRetry,
                      child: const Text(TracGoStrings.requisitionListRetry),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    final account = state.account;
    if (account == null) {
      return const SizedBox(key: ValueKey('none'), width: double.infinity);
    }

    return _Section(
      key: const ValueKey('content'),
      title: TracGoStrings.profileSectionAccount,
      rows: [
        KeyValueRow(
          TracGoStrings.profileEmployeeId,
          account.employeeId,
          placeholder: TracGoStrings.profileNotProvided,
        ),
        KeyValueRow(
          TracGoStrings.profileRole,
          account.roleId,
          placeholder: TracGoStrings.profileNotProvided,
        ),
        if (account.memberSince != null)
          KeyValueRow(
            TracGoStrings.profileMemberSince,
            _dateFormatter.format(account.memberSince!),
          ),
        if (account.lastPasswordChangedAt != null)
          KeyValueRow(
            TracGoStrings.profilePasswordChanged,
            _dateFormatter.format(account.lastPasswordChangedAt!),
          ),
      ],
    );
  }
}

/// The design pairs this with a "Change password" button. That is deliberately not
/// reproduced: the API exposes no password-change endpoint, and a button that opens
/// nothing is worse than an absent one.
class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggingOut = ref.watch(logoutNotifierProvider);

    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: tracGoDestructiveRedTint,
        foregroundColor: tracGoDestructiveRed,
        disabledForegroundColor: tracGoDestructiveRed.withValues(alpha: 0.6),
        shape: pillShape,
        textStyle: tracGoTextTheme.labelLarge?.copyWith(fontSize: 15),
      ),
      // Disabled while a sign-out is in flight: a second tap would fire another
      // `POST /logout` with a token the first call has already revoked.
      onPressed: isLoggingOut
          ? null
          : () async {
              // Captured before the await — the redirect to Login disposes this
              // widget, and the messenger above it survives.
              final messenger = ScaffoldMessenger.of(context);
              final result = await ref
                  .read(logoutNotifierProvider.notifier)
                  .logout();

              // null means a sign-out was already in flight — not a failure.
              if (result == null || result is ApiSuccess<void>) return;
              messenger.showSnackBar(
                const SnackBar(
                  content: Text(TracGoStrings.navLogoutRevokeFailed),
                ),
              );
            },
      child: isLoggingOut
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: tracGoDestructiveRed,
              ),
            )
          : const Text(TracGoStrings.navLogout),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({super.key, required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: SectionLabel(title),
        ),
        SurfaceCard.rows(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          rows: rows,
        ),
      ],
    );
  }
}
