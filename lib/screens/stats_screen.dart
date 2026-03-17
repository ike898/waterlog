import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/water_provider.dart';
import '../widgets/banner_ad_widget.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(waterEntriesProvider);
    final goal = ref.watch(dailyGoalProvider);
    final theme = Theme.of(context);

    return entriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bar_chart, size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text('Log water to see stats',
                    style: theme.textTheme.bodyLarge),
              ],
            ),
          );
        }

        // Calculate weekly stats
        final now = DateTime.now();
        final last7Days = List.generate(7, (i) {
          final day = now.subtract(Duration(days: i));
          return DateTime(day.year, day.month, day.day);
        });

        final dailyTotals = last7Days.map((day) {
          final nextDay = day.add(const Duration(days: 1));
          return entries
              .where((e) =>
                  e.timestamp.isAfter(day) && e.timestamp.isBefore(nextDay))
              .fold(0, (sum, e) => sum + e.amountMl);
        }).toList();

        final avgDaily = dailyTotals.fold(0, (a, b) => a + b) / 7;
        final daysGoalMet =
            dailyTotals.where((t) => t >= goal).length;
        final totalEntries = entries.length;

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      _StatCard(
                          title: 'Avg Daily',
                          value: '${avgDaily.round()} ml',
                          theme: theme),
                      const SizedBox(width: 8),
                      _StatCard(
                          title: 'Goals Met',
                          value: '$daysGoalMet / 7',
                          theme: theme),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatCard(
                          title: 'Total Logs',
                          value: '$totalEntries',
                          theme: theme),
                      const SizedBox(width: 8),
                      _StatCard(
                          title: 'Daily Goal',
                          value: '$goal ml',
                          theme: theme),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Last 7 Days', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...List.generate(7, (i) {
                    final day = last7Days[i];
                    final total = dailyTotals[i];
                    final ratio = goal > 0 ? (total / goal).clamp(0.0, 1.0) : 0.0;
                    const dayNames = [
                        'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
                    ];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Text(dayNames[day.weekday - 1],
                                style: theme.textTheme.bodySmall),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: ratio,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              color: total >= goal
                                  ? Colors.green
                                  : theme.colorScheme.primary,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 60,
                            child: Text('${total}ml',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const BannerAdWidget(),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final ThemeData theme;

  const _StatCard(
      {required this.title, required this.value, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(value,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
