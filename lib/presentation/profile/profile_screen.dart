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
      backgroundColor: tmsPageBackground,
      appBar: AppBar(
        title: Text(TmsStrings.profileTitle, style: tmsTextTheme.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: tmsTextDark),
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
                title: TmsStrings.profileSectionContact,
                rows: [
                  _Row(TmsStrings.profileEmail, user.email),
                  _Row(TmsStrings.profilePhone, user.phone),
                  _Row(TmsStrings.profileCompany, user.companyName),
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
        borderRadius: tmsBorderRadius(tmsRadiusLarge),
        gradient: const LinearGradient(colors: [tmsGreenLight, tmsGreenLightAlt]),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(color: tmsSurfaceWhite, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              _initialsOf(user.name),
              style: tmsTextTheme.titleMedium?.copyWith(color: tmsGreen),
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
                Text(user.name, style: tmsTextTheme.titleMedium),
                if (user.designation.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.designation,
                    style: tmsTextTheme.bodyMedium?.copyWith(color: tmsTextSubtle),
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
        title: TmsStrings.profileSectionAccount,
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
        title: TmsStrings.profileSectionAccount,
        rows: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TmsStrings.profileAccountUnavailable,
                  style: tmsTextTheme.bodyMedium?.copyWith(color: tmsTextDark),
                ),
                const SizedBox(height: 4),
                Text(
                  error,
                  style: tmsTextTheme.bodySmall?.copyWith(color: tmsTextMutedAlt),
                ),
                // Withheld for terminal failures such as 403, where a second attempt
                // cannot produce a different answer.
                if (state.canRetry) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(shape: pillShape),
                    child: const Text(TmsStrings.requisitionListRetry),
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
      title: TmsStrings.profileSectionAccount,
      rows: [
        _Row(TmsStrings.profileEmployeeId, account.employeeId),
        _Row(TmsStrings.profileRole, account.roleId),
        _Row(TmsStrings.profileStatus, account.activeStatus),
        if (account.memberSince != null)
          _Row(
            TmsStrings.profileMemberSince,
            _dateFormatter.format(account.memberSince!),
          ),
        if (account.lastPasswordChangedAt != null)
          _Row(
            TmsStrings.profilePasswordChanged,
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
            style: tmsTextTheme.labelMedium?.copyWith(color: tmsGreen),
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
        ? TmsStrings.profileNotProvided
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
              style: tmsTextTheme.bodyMedium?.copyWith(color: tmsTextMutedAlt),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              display,
              style: tmsTextTheme.bodyMedium?.copyWith(
                color: isMissing ? tmsPlaceholder : tmsTextDark,
                fontWeight: isMissing ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
