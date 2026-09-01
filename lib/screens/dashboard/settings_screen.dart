import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/validators.dart';
import '../../models/owner_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui/feedback.dart';
import '../../widgets/ui/whimsical_button.dart';
import '../../widgets/ui/whimsical_text_field.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _slug = TextEditingController();
  final _bio = TextEditingController();
  final _keys = <TextEditingController>[];
  final _values = <TextEditingController>[];
  String? _logo;
  String? _qr;
  var _inited = false;
  var _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _slug.dispose();
    _bio.dispose();
    for (final c in [..._keys, ..._values]) {
      c.dispose();
    }
    super.dispose();
  }

  void _hydrate(OwnerProfile profile) {
    if (_inited) return;
    _inited = true;
    _name.text = profile.shopName;
    _slug.text = profile.shopSlug;
    _bio.text = profile.bio ?? '';
    _logo = profile.logoUrl;
    _qr = profile.ewalletQrUrl;
    if (profile.contactInfo.isEmpty) {
      _addRow('gcash', '');
    } else {
      for (final e in profile.contactInfo.entries) {
        _addRow(e.key, e.value);
      }
    }
  }

  void _addRow(String key, String value) {
    _keys.add(TextEditingController(text: key));
    _values.add(TextEditingController(text: value));
  }

  Future<void> _save(OwnerProfile current) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final contact = <String, String>{};
    for (var i = 0; i < _keys.length; i++) {
      final k = _keys[i].text.trim();
      if (k.isEmpty) continue;
      contact[k] = _values[i].text.trim();
    }
    await ref.read(ownerRepositoryProvider).upsert(
          current.copyWith(
            shopName: _name.text.trim(),
            shopSlug: _slug.text.trim(),
            bio: _bio.text.trim(),
            logoUrl: _logo,
            ewalletQrUrl: _qr,
            contactInfo: contact,
          ),
        );
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(myProfileProvider);
    return profile.when(
      loading: () => const DinoLoading(),
      error: (e, _) => WhimsicalError(message: e.toString()),
      data: (data) {
        if (data == null) {
          return const WhimsicalEmpty(
            title: 'No shop profile',
            body: 'Sign in with the owner account to edit your boutique details.',
          );
        }
        _hydrate(data);
        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              Text('The shop', style: AppTypography.displayMedium),
              const SizedBox(height: 18),
              WhimsicalTextField(
                controller: _name,
                label: 'Shop name',
                validator: (v) => Validators.requiredField(v, label: 'Name'),
              ),
              const SizedBox(height: 12),
              WhimsicalTextField(
                controller: _slug,
                label: 'Shareable slug',
                validator: Validators.slug,
              ),
              const SizedBox(height: 12),
              WhimsicalTextField(
                controller: _bio,
                label: 'Bio',
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              Text('Logo', style: AppTypography.label),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: WhimsicalButton(
                  label: 'Upload logo',
                  kind: WhimsicalButtonKind.ghost,
                  onPressed: () async {
                    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (file == null) return;
                    final url = await ref
                        .read(ownerRepositoryProvider)
                        .uploadLogo(await file.readAsBytes());
                    setState(() => _logo = url);
                  },
                ),
              ),
              const SizedBox(height: 18),
              Text('E-wallet QR', style: AppTypography.title),
              const SizedBox(height: 6),
              Text(
                'Customers see this when they check out with e-wallet.',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 8),
              if (_qr != null && _qr!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    width: 160,
                    height: 160,
                    child: DecoratedBox(
                      decoration: stickerFill(radius: 22, stroke: AppStroke.inkThin),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: ContainedMedia(url: _qr!, padding: 8),
                      ),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: WhimsicalButton(
                  label: _qr == null ? 'Upload QR' : 'Replace QR',
                  kind: WhimsicalButtonKind.ghost,
                  onPressed: () async {
                    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (file == null) return;
                    final url = await ref
                        .read(ownerRepositoryProvider)
                        .uploadWalletQr(await file.readAsBytes());
                    setState(() => _qr = url);
                  },
                ),
              ),
              const SizedBox(height: 18),
              Text('Contact notes', style: AppTypography.title),
              const SizedBox(height: 8),
              for (var i = 0; i < _keys.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(child: WhimsicalTextField(controller: _keys[i], hint: 'gcash')),
                      const SizedBox(width: 8),
                      Expanded(child: WhimsicalTextField(controller: _values[i], hint: '09XX')),
                    ],
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _addRow('', '')),
                  icon: const Icon(Icons.add),
                  label: const Text('Add row'),
                ),
              ),
              const SizedBox(height: 12),
              WhimsicalButton(
                label: 'Save shop',
                expand: true,
                busy: _saving,
                onPressed: () => _save(data),
              ),
              const SizedBox(height: 20),
              WhimsicalButton(
                label: 'Sign out',
                kind: WhimsicalButtonKind.ghost,
                expand: true,
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOut();
                  if (context.mounted) context.go('/dashboard/login');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
