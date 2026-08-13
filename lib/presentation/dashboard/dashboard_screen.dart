import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/requisition.dart';
import '../../theme/colors.dart';
import '../../theme/shapes.dart';
import '../../theme/typography.dart';
import '../common/requisition_row.dart';
import '../common/strings.dart';
import 'dashboard_notifier.dart';
import 'dashboard_state.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key, required this.onViewAllRequisitions, required this.onRequisitionNow});

  final VoidCallback onViewAllRequisitions;
  final VoidCallback onRequisitionNow;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  StreamSubscription<DashboardEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _eventSub = ref.read(dashboardNotifierProvider.notifier).events.listen((event) {
        if (!mounted) return;
        final message = switch (event) {
          DashboardSessionExpired(:final message) => message,
          DashboardRefreshFailed(:final message) => message,
        };
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      });
    });
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(dashboardNotifierProvider);
    final notifier = ref.read(dashboardNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: tmsPageBackground,
      body: switch (uiState) {
        DashboardLoading() => const Center(child: CircularProgressIndicator()),
        DashboardError(:final message) => _ErrorState(message: message, onRetry: notifier.load),
        DashboardSuccess(:final summary) => RefreshIndicator(
            onRefresh: notifier.refresh,
            child: _DashboardContent(
              summary: summary,
              onViewAllRequisitions: widget.onViewAllRequisitions,
              onRequisitionNow: widget.onRequisitionNow,
            ),
          ),
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text(TmsStrings.dashboardRetry)),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.summary, required this.onViewAllRequisitions, required this.onRequisitionNow});

  final DashboardSummary summary;
  final VoidCallback onViewAllRequisitions;
  final VoidCallback onRequisitionNow;

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Without this the dashboard cannot be over-scrolled when its content is
      // shorter than the viewport, and the enclosing RefreshIndicator never fires.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        _HeroCard(onRequisitionNow: onRequisitionNow),
        const SizedBox(height: 20),
        _StatPanel(summary: summary),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(TmsStrings.dashboardRecentRequisitions, style: tmsTextTheme.titleMedium),
            TextButton(
              onPressed: onViewAllRequisitions,
              child: Text(
                TmsStrings.dashboardViewAll,
                style: tmsTextTheme.bodyMedium?.copyWith(color: tmsGreen, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        if (summary.recentRequisitions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              TmsStrings.dashboardNoRecentRequisitions,
              textAlign: TextAlign.center,
              style: tmsTextTheme.bodyMedium?.copyWith(color: tmsTextMutedAlt),
            ),
          )
        else
          for (final requisition in summary.recentRequisitions) ...[
            const SizedBox(height: 14),
            RequisitionRow(requisition: requisition),
          ],
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onRequisitionNow});

  final VoidCallback onRequisitionNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: tmsBorderRadius(tmsRadiusLarge),
        gradient: const LinearGradient(colors: [tmsGreenLight, tmsGreenLightAlt]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(TmsStrings.dashboardNeedVehicleTitle, style: tmsTextTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            TmsStrings.dashboardNeedVehicleSubtitle,
            style: tmsTextTheme.bodyMedium?.copyWith(color: tmsTextDark.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRequisitionNow,
            style: ElevatedButton.styleFrom(shape: pillShape),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(TmsStrings.dashboardRequisitionNow),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatSpec {
  const _StatSpec(this.count, this.label, this.icon, this.tint, this.tintBg);
  final int count;
  final String label;
  final IconData icon;
  final Color tint;
  final Color tintBg;
}

class _StatPanel extends StatelessWidget {
  const _StatPanel({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final gridSpecs = [
      _StatSpec(summary.allCount, TmsStrings.dashboardStatAll, Icons.assignment_outlined, tmsStatusAllPurple, tmsStatusAllPurpleBg),
      _StatSpec(summary.approvedCount, TmsStrings.dashboardStatApproved, Icons.event_available_outlined, tmsStatusApprovedGreen, tmsStatusApprovedGreenBg),
      _StatSpec(summary.assignedCount, TmsStrings.dashboardStatAssigned, Icons.check_box_outlined, tmsStatusAssignedTeal, tmsStatusAssignedTealBg),
      _StatSpec(summary.pendingCount, TmsStrings.dashboardStatPending, Icons.access_time_outlined, tmsStatusPendingOrange, tmsStatusPendingOrangeBg),
    ];
    final rejectedSpec = _StatSpec(summary.rejectedCount, TmsStrings.dashboardStatRejected, Icons.cancel_outlined, tmsStatusRejectedRed, tmsStatusRejectedRedBg);

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var rowStart = 0; rowStart < gridSpecs.length; rowStart += 2) ...[
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(child: _StatCell(spec: gridSpecs[rowStart])),
                  const VerticalDivider(width: 1, color: tmsDivider),
                  Expanded(child: _StatCell(spec: gridSpecs[rowStart + 1])),
                ],
              ),
            ),
            const Divider(height: 1, color: tmsDivider),
          ],
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _StatIconBadge(spec: rejectedSpec),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${rejectedSpec.count}', style: tmsTextTheme.titleLarge),
                    Text(rejectedSpec.label, style: tmsTextTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.spec});

  final _StatSpec spec;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatIconBadge(spec: spec),
          const SizedBox(height: 10),
          Text('${spec.count}', style: tmsTextTheme.titleLarge),
          const SizedBox(height: 2),
          Text(spec.label, style: tmsTextTheme.bodySmall),
        ],
      ),
    );
  }
}

class _StatIconBadge extends StatelessWidget {
  const _StatIconBadge({required this.spec});

  final _StatSpec spec;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: spec.tintBg, borderRadius: tmsBorderRadius(tmsRadiusExtraSmall)),
      alignment: Alignment.center,
      child: Icon(spec.icon, color: spec.tint, size: 18),
    );
  }
}
