import 'package:flutter/material.dart';

class DateRangeFilter extends StatefulWidget {
  final DateTime minDate;
  final DateTime maxDate;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime startDate, DateTime endDate) onDateRangeChanged;

  const DateRangeFilter({
    super.key,
    required this.minDate,
    required this.maxDate,
    this.initialStartDate,
    this.initialEndDate,
    required this.onDateRangeChanged,
  });

  @override
  State<DateRangeFilter> createState() => _DateRangeFilterState();
}

class _DateRangeFilterState extends State<DateRangeFilter> {
  late DateTime _startDate;
  late DateTime _endDate;
  String _selectedPreset = 'all';

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate ?? widget.minDate;
    _endDate = widget.initialEndDate ?? widget.maxDate;
  }

  void _applyPreset(String preset) {
    setState(() {
      _selectedPreset = preset;
      final now = DateTime.now();

      switch (preset) {
        case 'last_30':
          _startDate = now.subtract(const Duration(days: 30));
          _endDate = now;
          break;
        case 'last_90':
          _startDate = now.subtract(const Duration(days: 90));
          _endDate = now;
          break;
        case 'last_year':
          _startDate = DateTime(now.year - 1, now.month, now.day);
          _endDate = now;
          break;
        case 'this_year':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = now;
          break;
        case 'all':
          _startDate = widget.minDate;
          _endDate = widget.maxDate;
          break;
        case 'custom':
          // Don't change dates, just mark as custom
          break;
      }

      // Clamp dates to valid range
      if (_startDate.isBefore(widget.minDate)) {
        _startDate = widget.minDate;
      }
      if (_endDate.isAfter(widget.maxDate)) {
        _endDate = widget.maxDate;
      }

      widget.onDateRangeChanged(_startDate, _endDate);
    });
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: widget.minDate,
      lastDate: widget.maxDate,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedPreset = 'custom';
      });
      widget.onDateRangeChanged(_startDate, _endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.date_range, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Date Range Filter',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick Presets
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPresetChip('All Time', 'all'),
                _buildPresetChip('Last 30 Days', 'last_30'),
                _buildPresetChip('Last 90 Days', 'last_90'),
                _buildPresetChip('Last Year', 'last_year'),
                _buildPresetChip('This Year', 'this_year'),
                _buildPresetChip('Custom', 'custom'),
              ],
            ),

            const SizedBox(height: 16),

            // Current Selection Display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Date',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(_startDate),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, size: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'End Date',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(_endDate),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Custom Date Picker Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickDateRange,
                icon: const Icon(Icons.calendar_month),
                label: const Text('Select Custom Range'),
              ),
            ),

            const SizedBox(height: 8),

            // Date Range Info
            Text(
              _getDateRangeInfo(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, String value) {
    final isSelected = _selectedPreset == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _applyPreset(value);
        }
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _getDateRangeInfo() {
    final days = _endDate.difference(_startDate).inDays;
    final years = (days / 365).floor();

    if (years > 0) {
      return 'Showing data from $years ${years == 1 ? 'year' : 'years'} ($days days)';
    } else if (days > 30) {
      final months = (days / 30).floor();
      return 'Showing data from $months ${months == 1 ? 'month' : 'months'} ($days days)';
    } else {
      return 'Showing data from $days ${days == 1 ? 'day' : 'days'}';
    }
  }
}
