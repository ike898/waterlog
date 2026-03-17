import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/water_entry.dart';
import '../providers/water_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTotal = ref.watch(todayTotalProvider);
    final goal = ref.watch(dailyGoalProvider);
    final progress = ref.watch(todayProgressProvider);
    final todayEntries = ref.watch(todayEntriesProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Progress circle
        Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 12,
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                    color: progress >= 1.0
                        ? Colors.green
                        : theme.colorScheme.primary,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$todayTotal',
                      style: theme.textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '/ $goal ml',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                    if (progress >= 1.0)
                      Text('Goal reached!',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Quick add buttons
        Text('Quick Add', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DrinkContainer.defaults.map((c) {
            return ActionChip(
              avatar: Text(c.icon, style: const TextStyle(fontSize: 18)),
              label: Text('${c.amountMl}ml'),
              onPressed: () {
                ref
                    .read(waterEntriesProvider.notifier)
                    .addEntry(c.amountMl, containerName: c.name);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        // Today's entries
        if (todayEntries.isNotEmpty) ...[
          Text('Today', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...todayEntries.map((entry) => Dismissible(
                key: Key(entry.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  color: theme.colorScheme.error,
                  child:
                      Icon(Icons.delete, color: theme.colorScheme.onError),
                ),
                onDismissed: (_) {
                  ref
                      .read(waterEntriesProvider.notifier)
                      .deleteEntry(entry.id);
                },
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.water_drop,
                          color: theme.colorScheme.primary),
                    ),
                    title: Text('${entry.amountMl} ml'),
                    subtitle: Text(entry.containerName ?? ''),
                    trailing: Text(
                      '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
              )),
        ],
      ],
    );
  }
}
