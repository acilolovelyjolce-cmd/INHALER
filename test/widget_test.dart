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
      find.text('Welcome back').evaluate().isNotEmpty ||
          find.textContaining('Whimsical').evaluate().isNotEmpty,
      isTrue,
    );
  });
}

class _PlayedIntro extends IntroFlag {
  @override
  bool build() => true;
}
