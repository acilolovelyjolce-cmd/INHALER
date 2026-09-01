import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:whimsical_hub/data/demo_catalog.dart';
import 'package:whimsical_hub/main.dart';
import 'package:whimsical_hub/providers/intro_provider.dart';
import 'package:whimsical_hub/theme/app_theme.dart';
import 'package:whimsical_hub/widgets/storefront/mix_stage.dart';
import 'package:whimsical_hub/widgets/storefront/product_door_flow.dart';

void main() {
  testWidgets('app boots', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          introFlagProvider.overrideWith(_PlayedIntro.new),
        ],
        child: const WhimsicalApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(WhimsicalApp), findsOneWidget);
    expect(
      find.text('psst, owner').evaluate().isNotEmpty ||
          find.text('Owner atelier').evaluate().isNotEmpty ||
          find.text('Welcome back').evaluate().isNotEmpty ||
          find.textContaining('Whimsical').evaluate().isNotEmpty,
      isTrue,
    );
  });

  testWidgets('owner login is on screen and shop does not crash', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          introFlagProvider.overrideWith(_PlayedIntro.new),
        ],
        child: const WhimsicalApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('psst, owner'), findsOneWidget);
    expect(find.text('hop in'), findsOneWidget);

    await tester.ensureVisible(find.text('back to the public shop'));
    await tester.tap(find.text('back to the public shop'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('already been listened'), findsNothing);
    expect(find.textContaining('tiny charms'), findsWidgets);
  });

  testWidgets('mix preview stays compact while picking a paracord', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: ProductDoorFlow(product: demoProducts().first)),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
    expect(find.byType(MixStage), findsOneWidget);
    expect(tester.getSize(find.byType(MixStage)).height, lessThan(190));

    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Mint paracord'), findsOneWidget);

    await tester.tap(find.text('Mint paracord'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
    expect(find.byType(MixStage), findsOneWidget);
  });
}

class _PlayedIntro extends IntroFlag {
  @override
  bool build() => true;
}
