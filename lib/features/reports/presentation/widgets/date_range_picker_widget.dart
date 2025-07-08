import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/report_models.dart';
import '../providers/report_providers.dart';

class DateRangePickerWidget extends ConsumerWidget {
  const DateRangePickerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRange = ref.watch(selectedDateRangeProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedRange.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<DateRangePreset>(
                  child: const Row(
                    children: [
                      Text(
                        'Change',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.blue),
                    ],
                  ),
                  onSelected: (preset) async {
                    if (preset == DateRangePreset.custom) {
                      // Show date range picker
                      final DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now(),
                        initialDateRange: DateTimeRange(
                          start: selectedRange.startDate,
                          end: selectedRange.endDate,
                        ),
                      );
                      
                      if (picked != null) {
                        ref.read(selectedDateRangeProvider.notifier).state = ReportDateRange(
                          startDate: picked.start,
                          endDate: picked.end,
                          preset: DateRangePreset.custom,
                        );
                      }
                    } else {
                      ref.read(selectedDateRangeProvider.notifier).state = 
                          ReportDateRange.fromPreset(preset);
                    }
                  },
                  itemBuilder: (context) => DateRangePreset.values.map((preset) {
                    String label;
                    switch (preset) {
                      case DateRangePreset.today:
                        label = 'Today';
                        break;
                      case DateRangePreset.yesterday:
                        label = 'Yesterday';
                        break;
                      case DateRangePreset.thisWeek:
                        label = 'This Week';
                        break;
                      case DateRangePreset.lastWeek:
                        label = 'Last Week';
                        break;
                      case DateRangePreset.thisMonth:
                        label = 'This Month';
                        break;
                      case DateRangePreset.lastMonth:
                        label = 'Last Month';
                        break;
                      case DateRangePreset.last30Days:
                        label = 'Last 30 Days';
                        break;
                      case DateRangePreset.last90Days:
                        label = 'Last 90 Days';
                        break;
                      case DateRangePreset.thisYear:
                        label = 'This Year';
                        break;
                      case DateRangePreset.custom:
                        label = 'Custom Range...';
                        break;
                    }
                    
                    return PopupMenuItem<DateRangePreset>(
                      value: preset,
                      child: Row(
                        children: [
                          if (selectedRange.preset == preset)
                            const Icon(Icons.check, size: 18, color: Colors.blue)
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Text(label),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            if (selectedRange.preset == DateRangePreset.custom) ...[
              const SizedBox(height: 8),
              Text(
                '${_formatDate(selectedRange.startDate)} - ${_formatDate(selectedRange.endDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}