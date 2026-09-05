import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/session_store.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';
import 'widgets/deep_link_host.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 220;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 80 << 20;
  await SessionStore.instance.load();
  runApp(const ProviderScope(child: WhimsicalApp()));
}

class WhimsicalApp extends ConsumerWidget {
  const WhimsicalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Whimsical Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
      color: AppColors.cream,
      builder: (context, child) => DeepLinkHost(child: child ?? const SizedBox.shrink()),
    );
  }
}
