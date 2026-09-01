import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:whimsical_hub/main.dart';
import 'package:whimsical_hub/providers/intro_provider.dart';

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
}

class _PlayedIntro extends IntroFlag {
  @override
  bool build() => true;
}
