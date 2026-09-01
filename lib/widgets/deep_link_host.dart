import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../router/app_router.dart';
import '../platform/incoming_links.dart';

class DeepLinkHost extends ConsumerStatefulWidget {
  const DeepLinkHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<DeepLinkHost> createState() => _DeepLinkHostState();
}

class _DeepLinkHostState extends ConsumerState<DeepLinkHost> {
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;
    final links = AppLinks();
    _sub = links.uriLinkStream.listen(_open);
    links.getInitialLink().then(_open);
  }

  void _open(Uri? uri) {
    if (uri == null || !mounted) return;
    final location = locationFromIncomingUri(uri);
    if (location == null) return;
    ref.read(appRouterProvider).go(location);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
