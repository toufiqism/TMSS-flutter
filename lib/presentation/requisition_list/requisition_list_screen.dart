import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/model/requisition.dart';
import '../../theme/colors.dart';
import '../../theme/shapes.dart';
import '../../theme/typography.dart';
import '../common/requisition_row.dart';
import '../common/strings.dart';
import 'requisition_list_notifier.dart';
import 'requisition_list_state.dart';

final _chipDateFormatter = DateFormat('dd MMM');

class RequisitionListScreen extends ConsumerStatefulWidget {
  const RequisitionListScreen({super.key, required this.onNewRequisition});

  final VoidCallback onNewRequisition;

  @override
  ConsumerState<RequisitionListScreen> createState() => _RequisitionListScreenState();
}

class _RequisitionListScreenState extends ConsumerState<RequisitionListScreen> {
  final _scrollController = ScrollController();
  StreamSubscription<RequisitionListEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _eventSub = ref.read(requisitionListNotifierProvider.notifier).events.listen((event) {
        if (!mounted) return;
        final message = switch (event) {
          RequisitionListShowMessage(:final message) => message,
          RequisitionListSessionExpired(:final message) => message,
        };
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      });
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 400) {
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
        title: const Text(TmsStrings.requisitionListCancelConfirmTitle),
        content: const Text(TmsStrings.requisitionListCancelConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text(TmsStrings.requisitionListCancelConfirmNo)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text(TmsStrings.requisitionListCancelConfirmYes)),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ref.read(requisitionListNotifierProvider.notifier).cancelRequisition(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(requisitionListNotifierProvider);
    final notifier = ref.read(requisitionListNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: tmsPageBackground,
      bottomNavigationBar: SafeArea(
        child: Container(
          color: tmsSurfaceWhite,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: widget.onNewRequisition,
              style: ElevatedButton.styleFrom(shape: pillShape),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16),
                  SizedBox(width: 8),
                  Text(TmsStrings.requisitionListNewFab),
                ],
              ),
            ),
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
            child: switch (uiState) {
              RequisitionListUiState(isInitialLoading: true) => const Center(child: CircularProgressIndicator()),
              RequisitionListUiState(items: [], :final errorMessage) when errorMessage != null => _EmptyOrErrorState(message: errorMessage),
              RequisitionListUiState(items: []) => const _EmptyOrErrorState(message: TmsStrings.requisitionListEmpty),
              RequisitionListUiState(:final items, :final isLoadingMore) => ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  itemCount: items.length + (isLoadingMore ? 1 : 0),
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    if (index >= items.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                      );
                    }
                    final requisition = items[index];
                    return RequisitionRow(
                      requisition: requisition,
                      trailingAction: requisition.status == RequisitionStatus.pending
                          ? InkWell(
                              onTap: () => _confirmCancel(requisition.id),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  TmsStrings.requisitionListCancel,
                                  style: tmsTextTheme.bodyMedium?.copyWith(color: tmsDestructiveRed, fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          : null,
                    );
                  },
                ),
            },
          ),
        ],
      ),
    );
  }
}

enum _DatePickerTarget { start, end }

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
    final initial = (target == _DatePickerTarget.start ? widget.startDate : widget.endDate) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;

    final newStart = target == _DatePickerTarget.start ? picked : widget.startDate;
    final newEnd = target == _DatePickerTarget.end ? picked : widget.endDate;
    if (newStart != null && newEnd != null && newEnd.isBefore(newStart)) {
      setState(() => _rangeError = TmsStrings.requisitionListDateRangeInvalid);
      return;
    }
    setState(() => _rangeError = null);
    widget.onDateRangeChange(newStart, newEnd);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            initialValue: widget.searchQuery,
            onChanged: widget.onSearchQueryChange,
            decoration: const InputDecoration(
              hintText: TmsStrings.requisitionListSearchPlaceholder,
              prefixIcon: Icon(Icons.search, color: tmsTextSubtle),
              fillColor: tmsSurfaceWhite,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                _FilterPillChip(
                  label: widget.startDate != null ? _chipDateFormatter.format(widget.startDate!) : 'From',
                  onTap: () => _pickDate(_DatePickerTarget.start),
                ),
                const SizedBox(width: 8),
                _FilterPillChip(
                  label: widget.endDate != null ? _chipDateFormatter.format(widget.endDate!) : 'To',
                  onTap: () => _pickDate(_DatePickerTarget.end),
                ),
                const SizedBox(width: 8),
                const VerticalDivider(width: 1, color: tmsDivider),
                TextButton(
                  onPressed: () {
                    setState(() => _rangeError = null);
                    widget.onReset();
                  },
                  child: Text(
                    TmsStrings.requisitionListReset,
                    style: tmsTextTheme.bodyMedium?.copyWith(color: tmsGreen, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          if (_rangeError != null)
            Text(_rangeError!, style: tmsTextTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error)),
        ],
      ),
    );
  }
}

class _FilterPillChip extends StatelessWidget {
  const _FilterPillChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: pillBorderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: const BoxDecoration(color: tmsGreenLight, borderRadius: pillBorderRadius),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month, size: 15, color: tmsGreen),
            const SizedBox(width: 6),
            Text(label, style: tmsTextTheme.bodyMedium?.copyWith(color: tmsGreen, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrErrorState extends StatelessWidget {
  const _EmptyOrErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center, style: tmsTextTheme.bodyMedium?.copyWith(color: tmsTextMutedAlt)),
      ),
    );
  }
}
