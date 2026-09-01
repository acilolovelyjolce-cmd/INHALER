import 'package:web/web.dart' as web;

const _key = 'whimsical_hub.hasPlayedIntro';

bool readIntroPlayed() => web.window.sessionStorage.getItem(_key) == '1';

void writeIntroPlayed() => web.window.sessionStorage.setItem(_key, '1');
