import 'package:flutter/material.dart';

import '../../config/formatters.dart';
import '../../models/order_request.dart';
import '../../theme/tokens.dart';
import '../ui/whimsical_badge.dart';

class OrderListTile extends StatelessWidget {
  const OrderListTile({
    super.key,
    required this.order,
    required this.onTap,
    this.onDelete,
  });

  final OrderRequest order;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final color = switch (order.status) {
      OrderStatus.newRequest => AppColors.petal,
      OrderStatus.confirmed => AppColors.yolk,
      OrderStatus.preparing => AppColors.meadow,
      OrderStatus.ready => AppColors.meadow,
      OrderStatus.completed => AppColors.blush,
      OrderStatus.cancelled => AppColors.cancelled.withValues(alpha: 0.35),
    };

    return Material(
      color: AppColors.cloud,
      borderRadius: AppRadii.cardBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.cardBorder,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 48,
                decoration: ShapeDecoration(color: color, shape: const StadiumBorder()),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.customerName, style: AppTypography.price),
                    const SizedBox(height: 2),
                    Text(
                      '${order.items.length} item${order.items.length == 1 ? '' : 's'} · ${Formatters.dayTime.format(order.createdAt.toLocal())}',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Formatters.php(order.totalAmount), style: AppTypography.price),
                  const SizedBox(height: 6),
                  WhimsicalBadge(label: order.status.label, color: color),
                ],
              ),
              if (onDelete != null)
                IconButton(
                  tooltip: 'Delete request',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
