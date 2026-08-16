import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/model/requisition.dart';
import '../../theme/colors.dart';
import '../../theme/shapes.dart';
import '../../theme/typography.dart';
import '../common/choice_pill.dart';
import '../common/requisition_row.dart';
import '../common/section_label.dart';
import '../common/strings.dart';
import '../common/surface_card.dart';
import '../common/synced_text_field.dart';
import 'requisition_list_notifier.dart';
import 'requisition_list_state.dart';

final _chipDateFormatter = DateFormat('dd MMM');
final _dayHeaderFormatter = DateFormat('dd MMM yyyy');

/// One day's worth of rows, in the order the server returned them.
class _DayGroup {
  const _DayGroup(this.day, this.items);

  final DateTime day;
  final List<Requisition> items;
}

/// Splits the flat page into day groups without reordering it.
///
/// Consecutive runs only — the list is server-sorted and the sort field is
/// user-selectable, so bucketing by date globally would silently re-sort a list the
/// user asked to see by pickup or by status.
List<_DayGroup> _groupByDay(List<Requisition> items) {
  final groups = <_DayGroup>[];
  for (final item in items) {
    final at = item.pickupDateTime;
    final day = DateTime(at.year, at.month, at.day);
    if (groups.isNotEmpty && groups.last.day == day) {
      groups.last.items.add(item);
    } else {
      groups.add(_DayGroup(day, [item]));
    }
  }
  return groups;
}

/// "Today" / "Tomorrow" / "Yesterday" where that is unambiguous, an absolute date
/// otherwise — a reader should never have to work out what "in 2 days" means.
String _dayLabel(DateTime day, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final delta = day.difference(today).inDays;
  return switch (delta) {
    0 => TracGoStrings.requisitionListToday,
    1 => TracGoStrings.requisitionListTomorrow,
    -1 => TracGoStrings.requisitionListYesterday,
    _ => _dayHeaderFormatter.format(day),
  };
}

class RequisitionListScreen extends ConsumerStatefulWidget {
  const RequisitionListScreen({
    super.key,
    required this.onNewRequisition,
    required this.onOpenRequisition,
  });

  final VoidCallback onNewRequisition;
  final ValueChanged<Requisition> onOpenRequisition;

  @override
  ConsumerState<RequisitionListScreen> createState() =>
      _RequisitionListScreenState();
}

class _RequisitionListScreenState extends ConsumerState<RequisitionListScreen> {
  final _scrollController = ScrollController();
  StreamSubscription<RequisitionListEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _eventSub = ref
          .read(requisitionListNotifierProvider.notifier)
          .events
          .listen((event) {
            if (!mounted) return;
            final message = switch (event) {
              RequisitionListShowMessage(:final message) => message,
              RequisitionListSessionExpired(:final message) => message,
            };
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          });
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      ref.read(requisitionListNotifierProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _confirmCancel(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(TracGoStrings.requisitionListCancelConfirmTitle),
        content: const Text(TracGoStrings.requisitionListCancelConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(TracGoStrings.requisitionListCancelConfirmNo),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(TracGoStrings.requisitionListCancelConfirmYes),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref
          .read(requisitionListNotifierProvider.notifier)
          .cancelRequisition(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(requisitionListNotifierProvider);
    final notifier = ref.read(requisitionListNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: tracGoPageBackground,
      bottomNavigationBar: SafeArea(
        child: Container(
          color: tracGoSurfaceWhite,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          // Row(end), not Align(centerRight). Scaffold measures bottomNavigationBar with
          // *loose* constraints, and an Align without a heightFactor expands to the
          // largest size those allow — so this bar grew to roughly half the screen and
          // squeezed body to 154px. The Column above then had no free space left, the
          // Expanded list resolved to zero height, and the requisitions were built but
          // never laid out. A Row shrink-wraps vertically to its child.
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Flexible so the button shrinks to the bar rather than overflowing it
              // once its label wraps at large accessibility text sizes.
              Flexible(
                child: ElevatedButton(
                  onPressed: widget.onNewRequisition,
                  style: ElevatedButton.styleFrom(shape: pillShape),
                  // Flexible for the same reason as the dashboard's hero button: the
                  // label outgrows the button at large text scales and overflows the Row.
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16),
                      SizedBox(width: 8),
                      Flexible(child: Text(TracGoStrings.requisitionListNewFab)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          _SearchAndFilters(
            searchQuery: uiState.searchQuery,
            startDate: uiState.startDate,
            endDate: uiState.endDate,
            onSearchQueryChange: notifier.onSearchQueryChange,
            onDateRangeChange: notifier.onDateRangeChange,
            onReset: notifier.resetFilters,
          ),
          Expanded(
            // The list had no pull-to-refresh at all, which mattered because its only
            // other refresh trigger was changing a filter — a failed load left the user
            // with no way back short of restarting the app.
            child: RefreshIndicator(
              onRefresh: notifier.refresh,
              child: switch (uiState) {
                RequisitionListUiState(isInitialLoading: true) => const Center(
                  child: CircularProgressIndicator(),
                ),
                RequisitionListUiState(items: [], :final errorMessage)
                    when errorMessage != null =>
                  _EmptyOrErrorState(
                    message: errorMessage,
                    onRetry: () => unawaited(notifier.refresh()),
                  ),
                RequisitionListUiState(items: []) => const _EmptyOrErrorState(
                  message: TracGoStrings.requisitionListEmpty,
                ),
                RequisitionListUiState(:final items, :final isLoadingMore) =>
                  _GroupedList(
                    controller: _scrollController,
                    groups: _groupByDay(items),
                    isLoadingMore: isLoadingMore,
                    onOpenRequisition: widget.onOpenRequisition,
                    onCancel: (id) => unawaited(_confirmCancel(id)),
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupedList extends StatelessWidget {
  const _GroupedList({
    required this.controller,
    required this.groups,
    required this.isLoadingMore,
    required this.onOpenRequisition,
    required this.onCancel,
  });

  final ScrollController controller;
  final List<_DayGroup> groups;
  final bool isLoadingMore;
  final ValueChanged<Requisition> onOpenRequisition;
  final ValueChanged<String> onCancel;

  @override
  Widget build(BuildContext context) {
    // Resolved once per build rather than per group, so every header on screen agrees
    // about what "today" is even if the build straddles midnight.
    final now = DateTime.now();

    return ListView.builder(
      controller: controller,
      // Without this a short list cannot be over-scrolled, so RefreshIndicator never
      // fires on exactly the screens where the user most wants it (empty or
      // nearly-empty results).
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      itemCount: groups.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= groups.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final group = groups[index];
        return Padding(
          padding: EdgeInsets.only(top: index == 0 ? 0 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: SectionLabel(_dayLabel(group.day, now)),
              ),
              SurfaceCard.rows(
                rows: [
                  for (final requisition in group.items)
                    RequisitionRow(
                      requisition: requisition,
                      timeOnly: true,
                      onTap: () => onOpenRequisition(requisition),
                      trailingAction:
                          requisition.status == RequisitionStatus.pending
                          ? _CancelAction(
                              onTap: () => onCancel(requisition.id),
                            )
                          : null,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CancelAction extends StatelessWidget {
  const _CancelAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: pillBorderRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          TracGoStrings.requisitionListCancel,
          style: tracGoTextTheme.bodySmall?.copyWith(
            color: tracGoDestructiveRed,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

enum _DatePickerTarget { start, end }

/// The white header block under the top bar: search, then the date-range filters.
class _SearchAndFilters extends StatefulWidget {
  const _SearchAndFilters({
    required this.searchQuery,
    required this.startDate,
    required this.endDate,
    required this.onSearchQueryChange,
    required this.onDateRangeChange,
    required this.onReset,
  });

  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<String> onSearchQueryChange;
  final void Function(DateTime? start, DateTime? end) onDateRangeChange;
  final VoidCallback onReset;

  @override
  State<_SearchAndFilters> createState() => _SearchAndFiltersState();
}

class _SearchAndFiltersState extends State<_SearchAndFilters> {
  String? _rangeError;

  Future<void> _pickDate(_DatePickerTarget target) async {
    final now = DateTime.now();
    final initial =
        (target == _DatePickerTarget.start
            ? widget.startDate
            : widget.endDate) ??
        now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;

    final newStart = target == _DatePickerTarget.start
        ? picked
        : widget.startDate;
    final newEnd = target == _DatePickerTarget.end ? picked : widget.endDate;
    if (newStart != null && newEnd != null && newEnd.isBefore(newStart)) {
      setState(() => _rangeError = TracGoStrings.requisitionListDateRangeInvalid);
      return;
    }
    setState(() => _rangeError = null);
    widget.onDateRangeChange(newStart, newEnd);
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters =
        widget.startDate != null ||
        widget.endDate != null ||
        widget.searchQuery.isNotEmpty;

    return Container(
      color: tracGoSurfaceWhite,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SyncedTextField, not TextFormField(initialValue:) — tapping Reset clears
          // searchQuery in the notifier, and the old field kept the typed text on
          // screen while the list below it showed unfiltered results.
          SyncedTextField(
            value: widget.searchQuery,
            onChanged: widget.onSearchQueryChange,
            hintText: TracGoStrings.requisitionListSearchPlaceholder,
            textInputAction: TextInputAction.search,
            prefixIcon: const Icon(
              Icons.search,
              size: 20,
              color: tracGoTextMutedAlt,
            ),
            fillColor: tracGoInputBackground,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            // Wrap, not Row: two date chips plus Reset do not fit on one line at large
            // accessibility text sizes. Wrapping onto a second line keeps every filter
            // reachable instead of clipping Reset off the right edge.
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterPill(
                  icon: Icons.calendar_today_outlined,
                  label: widget.startDate != null
                      ? _chipDateFormatter.format(widget.startDate!)
                      : TracGoStrings.requisitionListFilterFrom,
                  selected: widget.startDate != null,
                  onTap: () => _pickDate(_DatePickerTarget.start),
                ),
                FilterPill(
                  icon: Icons.calendar_today_outlined,
                  label: widget.endDate != null
                      ? _chipDateFormatter.format(widget.endDate!)
                      : TracGoStrings.requisitionListFilterTo,
                  selected: widget.endDate != null,
                  onTap: () => _pickDate(_DatePickerTarget.end),
                ),
                // Only offered once something is actually filtered — a Reset that
                // resets nothing is a dead control taking up the row.
                if (hasFilters)
                  TextButton(
                    onPressed: () {
                      setState(() => _rangeError = null);
                      widget.onReset();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      TracGoStrings.requisitionListReset,
                      style: tracGoTextTheme.bodySmall?.copyWith(
                        color: tracGoGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_rangeError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _rangeError!,
                style: tracGoTextTheme.bodySmall?.copyWith(
                  color: tracGoDestructiveRed,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyOrErrorState extends StatelessWidget {
  const _EmptyOrErrorState({required this.message, this.onRetry});

  final String message;

  /// Null for the genuinely-empty case: there is nothing to retry when the server
  /// answered correctly with no rows.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    // Scrollable even though it holds a single centred block, so that
    // RefreshIndicator still has something to pull on when the list is empty.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: tracGoTextTheme.bodyMedium?.copyWith(
                      color: tracGoTextMutedAlt,
                    ),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: onRetry,
                      child: const Text(TracGoStrings.requisitionListRetry),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
