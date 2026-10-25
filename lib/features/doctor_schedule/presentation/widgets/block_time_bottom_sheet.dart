import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';

/// Modal bottom sheet for doctors to block clinical time.
/// Fields specified: date, start, end, repeat, reason.
class BlockTimeBottomSheet extends StatefulWidget {
  final DateTime initialDate;
  final TimeOfDay initialStartTime;
  final TimeOfDay initialEndTime;
  final String? initialReason;
  final Future<void> Function({
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String reason,
    required String repeat,
  }) onConfirm;

  const BlockTimeBottomSheet({
    super.key,
    required this.initialDate,
    this.initialStartTime = const TimeOfDay(hour: 12, minute: 0),
    this.initialEndTime = const TimeOfDay(hour: 13, minute: 0),
    this.initialReason,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime initialDate,
    TimeOfDay initialStartTime = const TimeOfDay(hour: 12, minute: 0),
    TimeOfDay initialEndTime = const TimeOfDay(hour: 13, minute: 0),
    String? initialReason,
    required Future<void> Function({
      required DateTime date,
      required TimeOfDay startTime,
      required TimeOfDay endTime,
      required String reason,
      required String repeat,
    }) onConfirm,
  }) {
    final tokens = ClinicalTokens.of(context);
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: tokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => BlockTimeBottomSheet(
        initialDate: initialDate,
        initialStartTime: initialStartTime,
        initialEndTime: initialEndTime,
        initialReason: initialReason,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<BlockTimeBottomSheet> createState() => _BlockTimeBottomSheetState();
}

class _BlockTimeBottomSheetState extends State<BlockTimeBottomSheet> {
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late String _selectedRepeat;
  late final TextEditingController _reasonController;

  bool _isSubmitting = false;

  static const List<String> _repeatOptions = ['None', 'Daily', 'Weekly'];
  static const List<String> _commonReasons = [
    'Lunch break',
    'Department meeting',
    'Emergency on-call',
    'Personal leave',
    'Administrative',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _startTime = widget.initialStartTime;
    _endTime = widget.initialEndTime;
    _selectedRepeat = 'None';
    _reasonController = TextEditingController(
      text: widget.initialReason ?? 'Lunch break',
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  Future<void> _handleConfirm() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await widget.onConfirm(
        date: _selectedDate,
        startTime: _startTime,
        endTime: _endTime,
        reason: reason,
        repeat: _selectedRepeat,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Time blocked successfully: $reason'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to block time: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: ClinicalTokens.screenSidePadding,
        right: ClinicalTokens.screenSidePadding,
        top: 12,
        bottom: bottomInset + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header Row: Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Block Time',
                  style: tokens.headlineStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                  color: tokens.textSecondary,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. Date Field
            Text(
              'Date',
              style: tokens.secondaryStyle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: tokens.background,
                  borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
                  border: Border.all(
                    color: tokens.border,
                    width: ClinicalTokens.borderWidth,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: tokens.bodyStyle,
                    ),
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 18,
                      color: tokens.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Start & End Time Row
            Row(
              children: [
                // Start Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start time',
                        style: tokens.secondaryStyle.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickStartTime,
                        borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: tokens.background,
                            borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
                            border: Border.all(
                              color: tokens.border,
                              width: ClinicalTokens.borderWidth,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _startTime.format(context),
                                style: tokens.bodyStyle,
                              ),
                              Icon(
                                Icons.access_time_outlined,
                                size: 18,
                                color: tokens.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // End Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End time',
                        style: tokens.secondaryStyle.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickEndTime,
                        borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: tokens.background,
                            borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
                            border: Border.all(
                              color: tokens.border,
                              width: ClinicalTokens.borderWidth,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _endTime.format(context),
                                style: tokens.bodyStyle,
                              ),
                              Icon(
                                Icons.access_time_outlined,
                                size: 18,
                                color: tokens.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 3. Repeat selector
            Text(
              'Repeat',
              style: tokens.secondaryStyle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: _repeatOptions.map((repeat) {
                final isSelected = _selectedRepeat == repeat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(repeat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedRepeat = repeat);
                    },
                    selectedColor: tokens.primary,
                    backgroundColor: tokens.background,
                    labelStyle: tokens.secondaryStyle.copyWith(
                      color: isSelected ? tokens.onPrimary : tokens.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ClinicalTokens.radiusPill),
                      side: BorderSide(
                        color: isSelected ? tokens.primary : tokens.border,
                        width: ClinicalTokens.borderWidth,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // 4. Reason field
            Text(
              'Reason',
              style: tokens.secondaryStyle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _reasonController,
              style: tokens.bodyStyle,
              decoration: InputDecoration(
                hintText: 'e.g. Lunch break, Department meeting',
                hintStyle: tokens.secondaryStyle,
                filled: true,
                fillColor: tokens.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
                  borderSide: BorderSide(
                    color: tokens.border,
                    width: ClinicalTokens.borderWidth,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
                  borderSide: BorderSide(
                    color: tokens.border,
                    width: ClinicalTokens.borderWidth,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
                  borderSide: BorderSide(color: tokens.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Quick reason suggestion chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _commonReasons.map((r) {
                return InkWell(
                  onTap: () {
                    _reasonController.text = r;
                  },
                  borderRadius: BorderRadius.circular(ClinicalTokens.radiusChip),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tokens.accentTint,
                      borderRadius: BorderRadius.circular(ClinicalTokens.radiusChip),
                    ),
                    child: Text(
                      r,
                      style: tokens.chipStyle.copyWith(
                        color: tokens.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.primary,
                  foregroundColor: tokens.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ClinicalTokens.radiusPill),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: tokens.onPrimary,
                        ),
                      )
                    : Text(
                        'Block Time',
                        style: tokens.cardTitleStyle.copyWith(
                          color: tokens.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
