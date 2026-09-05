import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/order_request.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/dashboard/order_detail_sheet.dart';
import '../../widgets/dashboard/order_list_tile.dart';
import '../../widgets/dashboard/delete_order.dart';
import '../../widgets/ui/feedback.dart';
import '../../widgets/ui/whimsical_badge.dart';
import '../../widgets/ui/whimsical_sheet.dart';
import '../../widgets/ui/whimsical_text_field.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  OrderStatus? _filter;
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inbox = ref.watch(liveOrdersProvider);

    return inbox.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      loading: () => const DinoLoading(message: 'listening for requests…'),
      error: (e, _) => WhimsicalError(
        message: e.toString(),
        onRetry: () => ref.invalidate(ordersInboxProvider),
      ),
      data: (orders) {
        final q = _query.text.trim().toLowerCase();
        final filtered = orders.where((o) {
          if (_filter != null && o.status != _filter) return false;
          if (q.isNotEmpty && !o.customerName.toLowerCase().contains(q)) return false;
          return true;
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Requests', style: AppTypography.displayMedium),
                  const SizedBox(height: 12),
                  WhimsicalTextField(
                    controller: _query,
                    hint: 'Search by name',
                    prefixIcon: Icons.search,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  WhimsicalSegmented<OrderStatus?>(
                    values: const [null, ...OrderStatus.values],
                    selected: _filter,
                    labelOf: (v) => v?.label ?? 'All',
                    onChanged: (v) => setState(() => _filter = v),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const WhimsicalEmpty(
                      title: 'No requests yet',
                      body:
                          'Share your link and watch this space come alive 🦕',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final order = filtered[index];
                        return OrderListTile(
                          order: order,
                          onTap: () => showWhimsicalSheet(
                            context: context,
                            builder: (_) => OrderDetailSheet(order: order),
                          ),
                          onDelete: () => confirmAndDeleteOrder(
                            context: context,
                            ref: ref,
                            order: order,
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
