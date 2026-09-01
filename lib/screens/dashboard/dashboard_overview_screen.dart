import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/formatters.dart';
import '../../models/order_request.dart';
import '../../platform/public_origin.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/dashboard/shop_link_card.dart';
import '../../widgets/ui/feedback.dart';
import '../../widgets/ui/whimsical_card.dart';

class DashboardOverviewScreen extends ConsumerWidget {
  const DashboardOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersInboxProvider);
    final profile = ref.watch(myProfileProvider);

    return orders.when(
      loading: () => const DinoLoading(message: 'counting today’s hugs…'),
      error: (e, _) => WhimsicalError(message: e.toString()),
      data: (list) {
        final now = DateTime.now();
        final today = list.where((o) {
          final d = o.createdAt.toLocal();
          return d.year == now.year && d.month == now.month && d.day == now.day;
        }).length;
        final pending = list
            .where((o) =>
                o.status == OrderStatus.newRequest ||
                o.status == OrderStatus.confirmed ||
                o.status == OrderStatus.preparing ||
                o.status == OrderStatus.ready)
            .length;
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekTotal = list
            .where((o) => o.createdAt.isAfter(weekStart) && o.status != OrderStatus.cancelled)
            .fold<double>(0, (sum, o) => sum + o.totalAmount);

        final slug = profile.valueOrNull?.shopSlug ?? 'whimsical';
        final hour = DateTime.now().hour;
        final hello = hour < 12
            ? 'Good morning'
            : hour < 18
                ? 'Good afternoon'
                : 'Good evening';

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Text(hello, style: AppTypography.bodySmall),
            const SizedBox(height: 4),
            Text('Here’s the nest today', style: AppTypography.displayMedium),
            const SizedBox(height: 22),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 640;
                final stats = [
                  _Stat(label: 'new today', value: '$today'),
                  _Stat(label: 'in motion', value: '$pending'),
                  _Stat(label: 'this week', value: Formatters.php(weekTotal)),
                ];
                if (wide) {
                  return Row(
                    children: [
                      for (var i = 0; i < stats.length; i++) ...[
                        if (i > 0) const SizedBox(width: 12),
                        Expanded(child: stats[i]),
                      ],
                    ],
                  );
                }
                return Column(
                  children: [
                    for (final s in stats) ...[s, const SizedBox(height: 10)],
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            ShopLinkCard(url: shopUrlFor(slug)),
            const SizedBox(height: 18),
            TextButton(
              onPressed: () => context.go('/dashboard/orders'),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text('See all requests →'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return WhimsicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTypography.displayMedium),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
