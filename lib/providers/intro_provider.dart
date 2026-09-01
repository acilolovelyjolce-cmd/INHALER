import '../platform/intro_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'intro_provider.g.dart';

@Riverpod(keepAlive: true)
class IntroFlag extends _$IntroFlag {
  @override
  bool build() => readIntroPlayed();

  void markPlayed() {
    writeIntroPlayed();
    state = true;
  }
}
