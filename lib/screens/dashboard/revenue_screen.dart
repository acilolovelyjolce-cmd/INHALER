import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/formatters.dart';
import '../../data/revenue.dart';
import '../../models/order_request.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/dashboard/order_detail_sheet.dart';
import '../../widgets/dashboard/delete_order.dart';
import '../../widgets/storefront/mix_bill.dart';
import '../../widgets/ui/feedback.dart';
import '../../widgets/ui/whimsical_badge.dart';
import '../../widgets/ui/whimsical_card.dart';
import '../../widgets/ui/whimsical_sheet.dart';

class RevenueScreen extends ConsumerWidget {
  const RevenueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(liveOrdersProvider);
    return inbox.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      loading: () => const DinoLoading(message: 'counting the pesos…'),
      error: (error, _) => WhimsicalError(
        message: error.toString(),
        onRetry: () => ref.invalidate(ordersInboxProvider),
      ),
      data: (orders) => RevenueTill(orders: orders),
    );
  }
}

class RevenueTill extends ConsumerStatefulWidget {
  const RevenueTill({super.key, required this.orders, this.now});

  final List<OrderRequest> orders;
  final DateTime? now;

  @override
  ConsumerState<RevenueTill> createState() => _RevenueTillState();
}

class _RevenueTillState extends ConsumerState<RevenueTill> {
  var _period = RevenuePeriod.today;
  DateTime? _day;

  DateTime get _now => widget.now ?? DateTime.now();

  RevenueReport get _report {
    return Revenue.of(
      widget.orders,
      Revenue.windowFor(_period, now: _now, day: _day),
    );
  }

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _day ?? Revenue.dayFloor(_now),
      firstDate: DateTime(_now.year - 3),
      lastDate: Revenue.dayFloor(_now),
      helpText: 'Which day should the till open?',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.petal,
              onPrimary: AppColors.plum,
              surface: AppColors.cloud,
              onSurface: AppColors.plum,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;
    setState(() {
      _period = RevenuePeriod.custom;
      _day = Revenue.dayFloor(picked);
    });
  }

  void _select(RevenuePeriod period) {
    if (period == RevenuePeriod.custom) {
      _pickDay();
      return;
    }
    setState(() => _period = period);
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Till', style: AppTypography.displayMedium),
              const SizedBox(height: 4),
              Text(
                'Every peso the nest took, guest by guest.',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 14),
              WhimsicalSegmented<RevenuePeriod>(
                values: RevenuePeriod.values,
                selected: _period,
                labelOf: (period) {
                  if (period == RevenuePeriod.custom) {
                    return _day == null || _period != RevenuePeriod.custom
                        ? 'A day'
                        : Formatters.day.format(_day!);
                  }
                  return switch (period) {
                    RevenuePeriod.today => 'Today',
                    RevenuePeriod.yesterday => 'Yesterday',
                    RevenuePeriod.week => 'Week',
                    RevenuePeriod.month => 'Month',
                    RevenuePeriod.custom => 'A day',
                  };
                },
                onChanged: _select,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              _TotalCard(report: report),
              const SizedBox(height: 18),
              if (report.orders.isEmpty)
                const WhimsicalEmpty(
                  title: 'Quiet stretch',
                  body:
                      'No paid orders in this window yet. Accepted unpaid requests stay in Requests until you mark them paid.',
                )
              else ...[
                Text(
                  'Guests · ${report.guests}',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 10),
                for (final order in report.orders) ...[
                  _GuestTakeCard(
                    order: order,
                    onOpen: () => showWhimsicalSheet(
                      context: context,
                      builder: (_) => OrderDetailSheet(order: order),
                    ),
                    onDelete: () => confirmAndDeleteOrder(
                      context: context,
                      ref: ref,
                      order: order,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
              if (report.cancelled.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Cancelled · not in the total',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 10),
                for (final order in report.cancelled) ...[
                  _CancelledCard(
                    order: order,
                    onDelete: () => confirmAndDeleteOrder(
                      context: context,
                      ref: ref,
                      order: order,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.report});

  final RevenueReport report;

  @override
  Widget build(BuildContext context) {
    return WhimsicalCard(
      color: AppColors.yolk,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NEST TAKE', style: AppTypography.kicker),
          const SizedBox(height: 6),
          Text(report.window.title, style: AppTypography.title),
          Text(report.window.subtitle, style: AppTypography.bodySmall),
          const SizedBox(height: 14),
          Text(Formatters.php(report.take), style: AppTypography.displayLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              WhimsicalBadge(
                label: '${report.guests} guest${report.guests == 1 ? '' : 's'}',
                color: AppColors.cloud,
              ),
              WhimsicalBadge(
                label: '${report.pieces} piece${report.pieces == 1 ? '' : 's'}',
                color: AppColors.cloud,
              ),
              WhimsicalBadge(
                label: '${Formatters.php(report.collected)} in',
                color: AppColors.meadow,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Only paid orders sit in the till. Accepted but unpaid requests stay in Requests until you mark them paid. Cancelled never counts.',
            style: AppTypography.bodySmall.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _GuestTakeCard extends StatelessWidget {
  const _GuestTakeCard({
    required this.order,
    required this.onOpen,
    required this.onDelete,
  });

  final OrderRequest order;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final payColor = switch (order.paymentStatus) {
      PaymentStatus.paid => AppColors.meadow,
      PaymentStatus.partial => AppColors.yolk,
      PaymentStatus.unpaid => AppColors.petal,
    };
    return WhimsicalCard(
      onTap: onOpen,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(order.customerName, style: AppTypography.title),
              ),
              const SizedBox(width: 10),
              Text(Formatters.php(order.totalAmount), style: AppTypography.displaySmall),
              IconButton(
                tooltip: 'Remove from till',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            [
              order.customerContact,
              Formatters.dayTime.format(order.createdAt.toLocal()),
              if (order.paymentMethod != null) order.paymentMethod!.label,
            ].join(' · '),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              WhimsicalBadge(label: order.status.label, color: AppColors.sky),
              WhimsicalBadge(label: order.paymentStatus.label, color: payColor),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < order.items.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            DecoratedBox(
              decoration: stickerFill(radius: 22, stroke: AppStroke.inkThin, elevated: false),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: MixBill(data: MixBillData.fromOrderItem(order.items[i])),
              ),
            ),
          ],
          if (order.customerNote != null && order.customerNote!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Guest note', style: AppTypography.label),
            const SizedBox(height: 4),
            Text(order.customerNote!, style: AppTypography.bodySmall.copyWith(height: 1.45)),
          ],
        ],
      ),
    );
  }
}

class _CancelledCard extends StatelessWidget {
  const _CancelledCard({required this.order, required this.onDelete});

  final OrderRequest order;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.62,
      child: WhimsicalCard(
        color: AppColors.blush,
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.customerName,
                    style: AppTypography.title.copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    Formatters.dayTime.format(order.createdAt.toLocal()),
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              Formatters.php(order.totalAmount),
              style: AppTypography.price.copyWith(decoration: TextDecoration.lineThrough),
            ),
            IconButton(
              tooltip: 'Remove from till',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
