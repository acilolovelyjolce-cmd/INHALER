import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:whimsical_hub/data/demo_catalog.dart';
import 'package:whimsical_hub/main.dart';
import 'package:whimsical_hub/providers/intro_provider.dart';
import 'package:whimsical_hub/theme/app_theme.dart';
import 'package:whimsical_hub/widgets/doodles/dino_mascot.dart';
import 'package:whimsical_hub/widgets/storefront/mix_stage.dart';
import 'package:whimsical_hub/widgets/storefront/product_door_flow.dart';
import 'package:whimsical_hub/widgets/ui/feedback.dart';
import 'package:whimsical_hub/widgets/ui/photo_lightbox.dart';
import 'package:whimsical_hub/widgets/ui/shop_mark.dart';

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
    expect(find.textContaining('Hand-finished inhaler charms'), findsOneWidget);
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
    expect(tester.getSize(find.byType(MixStage)).height, lessThan(210));

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

  testWidgets('mix summary lists a price for each part', (tester) async {
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
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Mint paracord'));
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Baby Rex'));
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Letterings of your initial?'), findsOneWidget);
    await tester.tap(find.text('No'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Pearl Rex'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('YOUR MIX'), findsOneWidget);
    expect(find.text('Inhaler'), findsOneWidget);
    expect(find.text('Mint paracord'), findsWidgets);
    expect(find.text('Baby Rex'), findsWidgets);
    expect(find.textContaining('₱450'), findsOneWidget);
    expect(find.textContaining('₱40'), findsOneWidget);
    expect(find.textContaining('₱80'), findsOneWidget);
    expect(find.textContaining('₱570'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
  });

  testWidgets('dashboard mark uses the suited cat until a logo is uploaded', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ShopMark(fallback: CatPose.owner)),
      ),
    );
    expect(find.byType(FluffyCat), findsOneWidget);
    expect(find.byType(SmartProductImage), findsNothing);
  });

  testWidgets('dashboard mark shows the uploaded logo instead of the cat', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShopMark(logoUrl: 'asset:assets/doodles/cats/cat_04.png'),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(FluffyCat), findsNothing);
    expect(find.byType(SmartProductImage), findsOneWidget);
  });

  testWidgets('paracord and trinket photos open full screen', (tester) async {
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
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const ValueKey('option-photo-cord-mint')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(PhotoLightbox), findsOneWidget);
    expect(find.text('Mint paracord'), findsWidgets);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(PhotoLightbox), findsNothing);

    await tester.tap(find.text('Mint paracord'));
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const ValueKey('option-photo-t-rex')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(PhotoLightbox), findsOneWidget);
    expect(find.text('Baby Rex'), findsWidgets);
  });

  testWidgets('lettering prompt yes shows letters and ropes, no skips to specials', (tester) async {
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
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Mint paracord'));
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Letterings of your initial?'), findsOneWidget);
    await tester.tap(find.text('Yes'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('LETTERINGS'), findsOneWidget);
    expect(find.text('ROPES'), findsOneWidget);
    expect(find.text('Letter A'), findsOneWidget);
    expect(find.text('Gold rope'), findsOneWidget);
    expect(find.text('Pick a letter and a rope'), findsOneWidget);

    await tester.tap(find.text('Letter A'));
    await tester.pump();
    await tester.ensureVisible(find.text('Gold rope'));
    await tester.pump();
    await tester.tap(find.text('Gold rope'));
    await tester.pump();
    expect(find.text('Next'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Pearl Rex'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('LETTERINGS'), findsOneWidget);
    expect(find.text('Gold rope'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Baby Rex'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Letterings of your initial?'), findsOneWidget);
    await tester.tap(find.text('No'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Pearl Rex'), findsOneWidget);
  });
}

class _PlayedIntro extends IntroFlag {
  @override
  bool build() => true;
}
