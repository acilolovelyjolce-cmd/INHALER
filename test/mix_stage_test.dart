import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:whimsical_hub/data/demo_catalog.dart';
import 'package:whimsical_hub/models/product.dart';
import 'package:whimsical_hub/theme/app_theme.dart';
import 'package:whimsical_hub/widgets/storefront/mix_layout.dart';
import 'package:whimsical_hub/widgets/storefront/mix_stage.dart';
import 'package:whimsical_hub/widgets/storefront/product_door_flow.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<MixStageState> pumpMix(
    WidgetTester tester, {
    ProductOption? paracord,
    List<ProductOption> trinkets = const [],
    List<ProductOption> letterings = const [],
    ProductOption? rope,
    List<ProductOption> specialTrinkets = const [],
    ValueNotifier<ProductOption?>? cordListenable,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Widget stage() {
      return MixStage(
        inhalerUrl: mixInhalerUrl(demoProducts().first),
        paracord: paracord ?? cordListenable?.value,
        trinkets: trinkets,
        letterings: letterings,
        rope: rope,
        specialTrinkets: specialTrinkets,
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: cordListenable == null
              ? stage()
              : ValueListenableBuilder<ProductOption?>(
                  valueListenable: cordListenable,
                  builder: (context, _, __) => stage(),
                ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
    return tester.state<MixStageState>(find.byType(MixStage));
  }

  Finder piece(String id) => find.byKey(MixStage.pieceKey(id));

  Future<void> tapPiece(WidgetTester tester, Finder finder) async {
    final rect = tester.getRect(finder);
    await tester.tapAt(rect.center);
    await tester.pump();
  }

  Future<void> dragPiece(WidgetTester tester, Finder finder, Offset delta) async {
    await tester.dragFrom(tester.getRect(finder).center, delta, touchSlopX: 0, touchSlopY: 0);
    await tester.pump();
  }

  testWidgets('renders lettering and special trinket pieces', (tester) async {
    await pumpMix(
      tester,
      letterings: [demoLetterings.first],
      rope: demoRopes.first,
      specialTrinkets: [demoSpecialTrinkets.first],
    );
    expect(piece(MixArrangement.letteringId(demoLetterings.first.id)), findsOneWidget);
    expect(piece(MixArrangement.ropeId(demoRopes.first.id)), findsOneWidget);
    expect(piece(MixArrangement.specialId(demoSpecialTrinkets.first.id)), findsOneWidget);
  });

  testWidgets('renders inhaler, paracord, and trinket pieces', (tester) async {
    await pumpMix(
      tester,
      paracord: demoCords.first,
      trinkets: [demoTrinkets.first],
    );
    expect(piece(MixArrangement.inhalerId), findsOneWidget);
    expect(piece(MixArrangement.cordId(demoCords.first.id)), findsOneWidget);
    expect(piece(MixArrangement.trinketId(demoTrinkets.first.id)), findsOneWidget);
    expect(find.textContaining('pull the corner to size'), findsOneWidget);
    expect(tester.getSize(find.byType(MixStage)).height, lessThan(210));
  });

  testWidgets('dragging a piece moves it and keeps it selected', (tester) async {
    final state = await pumpMix(tester, paracord: demoCords.first);
    final inhaler = piece(MixArrangement.inhalerId);
    final start = tester.getCenter(inhaler);

    await dragPiece(tester, inhaler, const Offset(36, 18));

    expect(state.debugSelected, MixArrangement.inhalerId);
    expect(state.debugTransforms[MixArrangement.inhalerId]!.dx, closeTo(36, 2));
    expect(state.debugTransforms[MixArrangement.inhalerId]!.dy, closeTo(18, 2));
    expect(tester.getCenter(inhaler).dx, closeTo(start.dx + 36, 3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tap shows a rotate handle and twisting it turns the piece', (tester) async {
    final state = await pumpMix(tester, paracord: demoCords.first);
    final cordId = MixArrangement.cordId(demoCords.first.id);
    final cordBox = tester.getRect(piece(cordId));
    await tester.tapAt(cordBox.topLeft + const Offset(12, 12));
    await tester.pump();
    expect(state.debugSelected, cordId);
    expect(find.byKey(MixStage.rotateKey(cordId)), findsOneWidget);

    await tester.drag(find.byKey(MixStage.rotateKey(cordId)), const Offset(0, 48), touchSlopX: 0, touchSlopY: 0);
    await tester.pump();
    expect(state.debugTransforms[cordId]!.dAngle.abs(), greaterThan(0.02));
    expect(tester.takeException(), isNull);
  });

  testWidgets('pulling the size handle enlarges the piece', (tester) async {
    final state = await pumpMix(tester, paracord: demoCords.first);
    final cordId = MixArrangement.cordId(demoCords.first.id);
    final cordBox = tester.getRect(piece(cordId));
    await tester.tapAt(cordBox.topLeft + const Offset(12, 12));
    await tester.pump();
    expect(find.byKey(MixStage.scaleKey(cordId)), findsOneWidget);
    final startWidth = tester.getSize(piece(cordId)).width;

    await tester.drag(find.byKey(MixStage.scaleKey(cordId)), const Offset(40, 40), touchSlopX: 0, touchSlopY: 0);
    await tester.pump();
    expect(state.debugTransforms[cordId]!.scale, greaterThan(1.02));
    expect(tester.getSize(piece(cordId)).width, greaterThan(startWidth));
    expect(tester.takeException(), isNull);
  });

  testWidgets('selected piece is stacked in front', (tester) async {
    final state = await pumpMix(
      tester,
      paracord: demoCords.first,
      trinkets: [demoTrinkets.first],
    );
    final cordId = MixArrangement.cordId(demoCords.first.id);
    final rect = tester.getRect(piece(cordId));
    await tester.tapAt(rect.topLeft + const Offset(12, 12));
    await tester.pump();
    expect(state.debugOrder.last, cordId);
  });

  testWidgets('reset control restores a moved piece', (tester) async {
    final state = await pumpMix(tester);
    final inhaler = piece(MixArrangement.inhalerId);
    await dragPiece(tester, inhaler, const Offset(28, 12));
    expect(state.debugTransforms[MixArrangement.inhalerId]!.isIdentity, isFalse);

    await tester.tap(find.byKey(MixStage.resetKey(MixArrangement.inhalerId)));
    await tester.pump();
    expect(state.debugTransforms.containsKey(MixArrangement.inhalerId), isFalse);
  });

  testWidgets('a tiny nudge snaps back so pieces can align', (tester) async {
    final state = await pumpMix(tester);
    await dragPiece(tester, piece(MixArrangement.inhalerId), const Offset(5, 8));
    final transform = state.debugTransforms[MixArrangement.inhalerId] ?? MixTransform.zero;
    expect(transform.dx.abs(), lessThan(1));
    expect(transform.dy.abs(), lessThan(1));
  });

  testWidgets('swapping the paracord keeps the inhaler arrangement', (tester) async {
    final cord = ValueNotifier<ProductOption?>(demoCords.first);
    addTearDown(cord.dispose);
    final state = await pumpMix(tester, cordListenable: cord);
    await dragPiece(tester, piece(MixArrangement.inhalerId), const Offset(22, 0));
    expect(state.debugTransforms[MixArrangement.inhalerId]!.dx, closeTo(22, 2));

    cord.value = demoCords.last;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(state.debugTransforms[MixArrangement.inhalerId]!.dx, closeTo(22, 2));
    expect(piece(MixArrangement.cordId(demoCords.last.id)), findsOneWidget);
    expect(piece(MixArrangement.cordId(demoCords.first.id)), findsNothing);
  });

  testWidgets('mix stays compact inside the product door flow', (tester) async {
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
    await tester.tap(find.text('Mint paracord'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(piece(MixArrangement.cordId('cord-mint')), findsOneWidget);

    await dragPiece(tester, piece(MixArrangement.cordId('cord-mint')), const Offset(-20, 10));
    final state = tester.state<MixStageState>(find.byType(MixStage));
    expect(state.debugTransforms[MixArrangement.cordId('cord-mint')]!.dx, closeTo(-20, 3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping empty space hides rotate and size handles', (tester) async {
    final state = await pumpMix(tester, paracord: demoCords.first);
    final cordId = MixArrangement.cordId(demoCords.first.id);
    final cordBox = tester.getRect(piece(cordId));
    await tester.tapAt(cordBox.topLeft + const Offset(12, 12));
    await tester.pump();
    expect(state.debugSelected, cordId);
    expect(find.byKey(MixStage.rotateKey(cordId)), findsOneWidget);
    expect(find.byKey(MixStage.scaleKey(cordId)), findsOneWidget);

    final stageBox = tester.getRect(find.byType(MixStage));
    await tester.tapAt(stageBox.topLeft + const Offset(8, 8));
    await tester.pump();
    expect(state.debugSelected, isNull);
    expect(find.byKey(MixStage.rotateKey(cordId)), findsNothing);
    expect(find.byKey(MixStage.scaleKey(cordId)), findsNothing);
    expect(find.byKey(MixStage.resetKey(cordId)), findsNothing);
  });
}
