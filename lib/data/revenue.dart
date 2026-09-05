import '../config/formatters.dart';
import '../models/order_request.dart';

enum RevenuePeriod { today, yesterday, week, month, custom }

class RevenueWindow {
  const RevenueWindow({
    required this.period,
    required this.start,
    required this.end,
    required this.title,
  });

  final RevenuePeriod period;
  final DateTime start;
  final DateTime end;
  final String title;

  String get subtitle => Formatters.span(start, end);

  bool contains(DateTime instant) {
    final local = instant.toLocal();
    return !local.isBefore(start) && local.isBefore(end);
  }
}

class RevenueReport {
  const RevenueReport({
    required this.window,
    required this.orders,
    required this.cancelled,
  });

  final RevenueWindow window;
  final List<OrderRequest> orders;
  final List<OrderRequest> cancelled;

  double get take => orders.fold<double>(0, (sum, order) => sum + order.totalAmount);

  double get collected => orders
      .where((order) => order.paymentStatus == PaymentStatus.paid)
      .fold<double>(0, (sum, order) => sum + order.totalAmount);

  double get open => take - collected;

  int get guests => orders.length;

  int get pieces => orders.fold<int>(
        0,
        (sum, order) =>
            sum + order.items.fold<int>(0, (inner, item) => inner + item.quantity),
      );

  int get paidGuests =>
      orders.where((order) => order.paymentStatus == PaymentStatus.paid).length;
}

abstract final class Revenue {
  static DateTime dayFloor(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  static RevenueWindow windowFor(
    RevenuePeriod period, {
    required DateTime now,
    DateTime? day,
  }) {
    final today = dayFloor(now);
    final tomorrow = today.add(const Duration(days: 1));
    switch (period) {
      case RevenuePeriod.today:
        return RevenueWindow(period: period, start: today, end: tomorrow, title: 'Today');
      case RevenuePeriod.yesterday:
        final yesterday = today.subtract(const Duration(days: 1));
        return RevenueWindow(
          period: period,
          start: yesterday,
          end: today,
          title: 'Yesterday',
        );
      case RevenuePeriod.week:
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        return RevenueWindow(
          period: period,
          start: weekStart,
          end: weekStart.add(const Duration(days: 7)),
          title: 'This week',
        );
      case RevenuePeriod.month:
        final monthStart = DateTime(today.year, today.month);
        final monthEnd = DateTime(today.year, today.month + 1);
        return RevenueWindow(
          period: period,
          start: monthStart,
          end: monthEnd,
          title: Formatters.monthYear.format(monthStart),
        );
      case RevenuePeriod.custom:
        final picked = dayFloor(day ?? now);
        return RevenueWindow(
          period: period,
          start: picked,
          end: picked.add(const Duration(days: 1)),
          title: Formatters.weekday.format(picked),
        );
    }
  }

  static RevenueReport of(Iterable<OrderRequest> all, RevenueWindow window) {
    final inside = [
      for (final order in all)
        if (window.contains(order.createdAt)) order,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return RevenueReport(
      window: window,
      orders: [
        for (final order in inside)
          if (order.status != OrderStatus.cancelled &&
              order.paymentStatus == PaymentStatus.paid)
            order,
      ],
      cancelled: [
        for (final order in inside)
          if (order.status == OrderStatus.cancelled) order,
      ],
    );
  }
}
