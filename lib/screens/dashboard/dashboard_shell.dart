import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../platform/haptic.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/intro_provider.dart';
import '../../theme/breakpoints.dart';
import '../../theme/tokens.dart';
import '../../widgets/intro/intro_orchestrator.dart';

class DashboardShell extends ConsumerStatefulWidget {
  const DashboardShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell> {
  late final ConfettiController _confetti;

  static const _tabs = [
    _Tab('/dashboard', 'Home', Icons.home_outlined, Icons.home_rounded),
    _Tab('/dashboard/products', 'Catalog', Icons.auto_awesome_outlined, Icons.auto_awesome),
    _Tab('/dashboard/orders', 'Requests', Icons.inbox_outlined, Icons.inbox),
    _Tab('/dashboard/settings', 'Shop', Icons.storefront_outlined, Icons.storefront),
  ];

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 1100));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(orderCelebrationProvider, (prev, next) {
      if (prev != null && next > prev) {
        _confetti.play();
        whimsyHaptic();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A new request just landed 💌')),
        );
      }
    });

    final location = GoRouterState.of(context).uri.path;
    var currentIndex = 0;
    for (var i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].path ||
          (i > 0 && location.startsWith(_tabs[i].path))) {
        currentIndex = i;
      }
    }
    final compact = Breakpoints.isCompact(context);
    final introPlayed = ref.watch(introFlagProvider);

    final navRail = NavigationRail(
      backgroundColor: Colors.transparent,
      selectedIndex: currentIndex,
      onDestinationSelected: (i) => context.go(_tabs[i].path),
      labelType: NavigationRailLabelType.all,
      indicatorColor: AppColors.petal,
      selectedLabelTextStyle: AppTypography.label.copyWith(color: AppColors.plum),
      unselectedLabelTextStyle: AppTypography.label,
      destinations: [
        for (final tab in _tabs)
          NavigationRailDestination(
            icon: Icon(tab.icon),
            selectedIcon: Icon(tab.selectedIcon),
            label: Text(tab.label),
          ),
      ],
    );

    final bottom = NavigationBar(
      backgroundColor: AppColors.cloud,
      indicatorColor: AppColors.petal,
      selectedIndex: currentIndex,
      onDestinationSelected: (i) => context.go(_tabs[i].path),
      destinations: [
        for (final tab in _tabs)
          NavigationDestination(
            icon: Icon(tab.icon),
            selectedIcon: Icon(tab.selectedIcon),
            label: tab.label,
          ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.blush,
      body: Stack(
        children: [
          IntroOrchestrator(
            wordmark: 'Whimsical',
            hasPlayedIntro: introPlayed,
            onIntroComplete: () => ref.read(introFlagProvider.notifier).markPlayed(),
            child: Row(
              children: [
                if (!compact) navRail,
                Expanded(child: widget.child),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.12,
              numberOfParticles: 16,
              maxBlastForce: 14,
              minBlastForce: 5,
              gravity: 0.28,
              colors: const [AppColors.petal, AppColors.meadow, AppColors.yolk],
            ),
          ),
        ],
      ),
      bottomNavigationBar: compact ? bottom : null,
    );
  }
}

class _Tab {
  const _Tab(this.path, this.label, this.icon, this.selectedIcon);
  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
