import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/order_request.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/tokens.dart';

Future<bool> confirmAndDeleteOrder({
  required BuildContext context,
  required WidgetRef ref,
  required OrderRequest order,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Remove this request?'),
        content: Text(
          '${order.customerName}’s order will leave Requests and the till. It will no longer count in nest take. This cannot be undone.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      );
    },
  );
  if (ok != true) return false;
  try {
    await ref.read(ordersRepositoryProvider).delete(order.id);
    ref.invalidate(ordersInboxProvider);
    ref.invalidate(ownerProductsProvider);
    ref.invalidate(publishedProductsProvider(order.shopSlug));
    return true;
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
    return false;
  }
}
