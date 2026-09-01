import 'intro_session_stub.dart'
    if (dart.library.html) 'intro_session_web.dart' as impl;

bool readIntroPlayed() => impl.readIntroPlayed();

void writeIntroPlayed() => impl.writeIntroPlayed();
