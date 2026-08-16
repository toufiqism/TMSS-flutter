import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/model/user.dart';
import '../../theme/colors.dart';
import '../../theme/shapes.dart';
import '../../theme/typography.dart';
import '../../di/providers.dart';
import '../common/safe_insets.dart';
import '../common/strings.dart';
import 'profile_notifier.dart';
import 'profile_state.dart';

final _dateFormatter = DateFormat('dd MMM yyyy');

const _honorifics = {'md', 'md.', 'mr', 'mr.', 'mrs', 'mrs.', 'ms', 'ms.', 'dr', 'dr.'};

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
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(event.message)));
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

    return Scaffold(
      backgroundColor: tracGoPageBackground,
      appBar: AppBar(
        title: Text(TracGoStrings.profileTitle, style: tracGoTextTheme.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: tracGoTextDark),
          onPressed: widget.onBack,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: notifier.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20).addBottomSystemInset(context),
          children: [
            if (user != null) ...[
              _IdentityCard(user: user),
              const SizedBox(height: 16),
              _Section(
                title: TracGoStrings.profileSectionContact,
                rows: [
                  _Row(TracGoStrings.profileEmail, user.email),
                  _Row(TracGoStrings.profilePhone, user.phone),
                  _Row(TracGoStrings.profileCompany, user.companyName),
                ],
              ),
              const SizedBox(height: 16),
            ],
            _AccountSection(
              state: uiState,
              onRetry: () => unawaited(notifier.load()),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: tracGoBorderRadius(tracGoRadiusLarge),
        gradient: const LinearGradient(colors: [tracGoGreenLight, tracGoGreenLightAlt]),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(color: tracGoSurfaceWhite, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              _initialsOf(user.name),
              style: tracGoTextTheme.titleMedium?.copyWith(color: tracGoGreen),
            ),
          ),
          const SizedBox(width: 16),
          // Expanded, not a bare Column: a long name plus the avatar overflows the row
          // at large accessibility text sizes otherwise.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(user.name, style: tracGoTextTheme.titleMedium),
                if (user.designation.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.designation,
                    style: tracGoTextTheme.bodyMedium?.copyWith(color: tracGoTextSubtle),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.state, required this.onRetry});

  final ProfileUiState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const _Section(
        title: TracGoStrings.profileSectionAccount,
        rows: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ],
      );
    }

    final error = state.errorMessage;
    if (error != null) {
      return _Section(
        title: TracGoStrings.profileSectionAccount,
        rows: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TracGoStrings.profileAccountUnavailable,
                  style: tracGoTextTheme.bodyMedium?.copyWith(color: tracGoTextDark),
                ),
                const SizedBox(height: 4),
                Text(
                  error,
                  style: tracGoTextTheme.bodySmall?.copyWith(color: tracGoTextMutedAlt),
                ),
                // Withheld for terminal failures such as 403, where a second attempt
                // cannot produce a different answer.
                if (state.canRetry) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(shape: pillShape),
                    child: const Text(TracGoStrings.requisitionListRetry),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    final account = state.account;
    if (account == null) return const SizedBox.shrink();

    return _Section(
      title: TracGoStrings.profileSectionAccount,
      rows: [
        _Row(TracGoStrings.profileEmployeeId, account.employeeId),
        _Row(TracGoStrings.profileRole, account.roleId),
        _Row(TracGoStrings.profileStatus, account.activeStatus),
        if (account.memberSince != null)
          _Row(
            TracGoStrings.profileMemberSince,
            _dateFormatter.format(account.memberSince!),
          ),
        if (account.lastPasswordChangedAt != null)
          _Row(
            TracGoStrings.profilePasswordChanged,
            _dateFormatter.format(account.lastPasswordChangedAt!),
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            title.toUpperCase(),
            style: tracGoTextTheme.labelMedium?.copyWith(color: tracGoGreen),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Column(children: rows),
          ),
        ),
      ],
    );
  }
}

/// A label/value pair. A null or blank value renders as "Not provided" rather than an
/// empty gap, so a missing field is visibly missing instead of silently absent.
class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final display = (value == null || value!.trim().isEmpty)
        ? TracGoStrings.profileNotProvided
        : value!;
    final isMissing = value == null || value!.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Proportional rather than a fixed width, so the split stays sane at every
          // text scale.
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: tracGoTextTheme.bodyMedium?.copyWith(color: tracGoTextMutedAlt),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              display,
              style: tracGoTextTheme.bodyMedium?.copyWith(
                color: isMissing ? tracGoPlaceholder : tracGoTextDark,
                fontWeight: isMissing ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
