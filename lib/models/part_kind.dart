enum PartKind {
  paracord,
  trinket,
  lettering,
  rope,
  specialTrinket;

  String get apiValue => switch (this) {
        paracord => 'paracord',
        trinket => 'trinket',
        lettering => 'lettering',
        rope => 'rope',
        specialTrinket => 'special_trinket',
      };

  String get noun => switch (this) {
        paracord => 'paracord',
        trinket => 'trinket',
        lettering => 'lettering',
        rope => 'rope',
        specialTrinket => 'special trinket',
      };

  String get plural => switch (this) {
        paracord => 'paracords',
        trinket => 'trinkets',
        lettering => 'letterings',
        rope => 'ropes',
        specialTrinket => 'special trinkets',
      };

  String get addLabel => switch (this) {
        paracord => 'Add paracord',
        trinket => 'Add trinkets',
        lettering => 'Add letterings',
        rope => 'Add ropes',
        specialTrinket => 'Add special trinket',
      };

  String get hint => switch (this) {
        paracord => 'Mint paracord',
        trinket => 'Baby Rex',
        lettering => 'Letter A',
        rope => 'Gold rope',
        specialTrinket => 'Pearl dino',
      };

  String get formHelp => switch (this) {
        paracord =>
          'This cord is offered on every inhaler. Customers pick one color.',
        trinket =>
          'This charm is offered on every inhaler. Customers can pick as many as they like.',
        lettering =>
          'This lettering is offered on every inhaler. Customers who want initials can pick as many as they like.',
        rope =>
          'This rope is offered with letterings. Customers who add initials must pick one.',
        specialTrinket =>
          'This special trinket is offered on every inhaler. Customers can pick as many as they like.',
      };

  String get emptyTitle => 'No $plural yet';

  String get emptyBody => switch (this) {
        paracord => 'Add a cord color once. It will show up as an option on every inhaler.',
        trinket => 'Add a charm once. It will show up as an option on every inhaler.',
        lettering => 'Add a lettering once. Shoppers who want initials will see it on every inhaler.',
        rope => 'Add a rope once. Shoppers who pick letterings must choose one.',
        specialTrinket =>
          'Add a special trinket once. It will show up as an option on every inhaler.',
      };

  bool get pickOne => this == PartKind.paracord || this == PartKind.rope;

  static PartKind parse(String? raw) {
    final key = (raw ?? '').trim().toLowerCase().replaceAll(' ', '_');
    return switch (key) {
      'trinket' => trinket,
      'lettering' || 'letter' || 'letters' => lettering,
      'rope' || 'ropes' => rope,
      'special_trinket' || 'special' || 'specialtrinket' => specialTrinket,
      _ => paracord,
    };
  }
}
