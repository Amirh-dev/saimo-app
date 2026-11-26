/// The study hall character: a chibi/anime figure built from parts, drawn as
/// an SVG string (flutter_svg renders it). Port of
/// docs/design/study-hall/anime-avatar.js; keep the two in step.
///
/// Coordinates: origin at the bottom centre, the head around y = -96.
library;

const hallSkins = ['#FFE8DA', '#F8D9C4', '#EBC2A2', '#C99A76', '#8F6449'];
const hallHairColors = ['#2B2433', '#4A3328', '#7A4B33', '#C58B5A', '#EBCB8B', '#E79AAF', '#8FA6D8', '#B9B6C9'];
const hallEyeColors = ['#6B4130', '#C27A2C', '#3D6FB6', '#3E8A63', '#7E58B5', '#B8354A'];
const hallTopColors = ['#6F7C8F', '#2E3A59', '#B4A89A', '#3F5B4F', '#C98B7A', '#E8E1D6', '#8E7CA8', '#23232B'];

/// Items earned by your best study day (hours). One is worn at a time.
const hallRewards = [
  (id: 'beanie', name: 'کلاه بافتنی', hours: 2),
  (id: 'scarf', name: 'شال‌گردن', hours: 4),
  (id: 'goldphones', name: 'هدفون طلایی', hours: 6),
  (id: 'star', name: 'گیره‌ی ستاره', hours: 8),
  (id: 'gradcap', name: 'کلاه فارغ‌التحصیلی', hours: 10),
];

/// Whether a best day of [bestDaySeconds] unlocks reward [id].
bool hallRewardUnlocked(String id, int bestDaySeconds) =>
    hallRewards.any((r) => r.id == id && bestDaySeconds >= r.hours * 3600);

const hallHairs = ['long', 'wavy', 'twin', 'pony', 'bob', 'bun', 'wolf', 'spiky', 'ahoge', 'short', 'side', 'curly', 'buzz'];

class HallAvatar {
  const HallAvatar({
    this.skin = 1,
    this.hair = 'short',
    this.hairColor = 0,
    this.eyes = 'sharp',
    this.eyeColor = 0,
    this.blush = false,
    this.brows = 'thick',
    this.mouth = 'smile',
    this.face = 'strong',
    this.beard = 'none',
    this.top = 'hoodie',
    this.topColor = 1,
    this.accessories = const {'headphones'},
    this.boy = true,
    this.reward = '',
  });

  /// One item from [hallRewards], or '' for none.
  final String reward;

  final int skin;
  final String hair;
  final int hairColor;
  final String eyes;
  final int eyeColor;
  final bool blush;
  final String brows;
  final String mouth;
  final String face;
  final String beard;
  final String top;
  final int topColor;
  final Set<String> accessories;

  /// Boys get their own build: broader shoulders, a thicker neck, a squarer
  /// jaw, smaller sharp eyes without lashes, low straight brows, no blush.
  final bool boy;

  HallAvatar copyWith({
    int? skin, String? hair, int? hairColor, String? eyes, int? eyeColor, bool? blush, String? brows,
    String? mouth, String? face, String? beard, String? top, int? topColor, Set<String>? accessories, bool? boy, String? reward,
  }) =>
      HallAvatar(
        skin: skin ?? this.skin, hair: hair ?? this.hair, hairColor: hairColor ?? this.hairColor, eyes: eyes ?? this.eyes,
        eyeColor: eyeColor ?? this.eyeColor, blush: blush ?? this.blush, brows: brows ?? this.brows, mouth: mouth ?? this.mouth,
        face: face ?? this.face, beard: beard ?? this.beard, top: top ?? this.top, topColor: topColor ?? this.topColor,
        accessories: accessories ?? this.accessories, boy: boy ?? this.boy, reward: reward ?? this.reward,
      );

  Map<String, dynamic> toJson() => {
        'skin': skin, 'hair': hair, 'hairColor': hairColor, 'eyes': eyes, 'eyeColor': eyeColor, 'blush': blush,
        'brows': brows, 'mouth': mouth, 'face': face, 'beard': beard, 'top': top, 'topColor': topColor,
        'accessories': accessories.toList(), 'boy': boy, if (reward.isNotEmpty) 'reward': reward,
      };

  static HallAvatar fromJson(Map<String, dynamic> j) {
    int idx(String k, int max, int d) => ((j[k] as num?)?.toInt() ?? d).clamp(0, max - 1);
    // Missing parts take the defaults of the character's side.
    final boy = j['boy'] != false;
    return HallAvatar(
      skin: idx('skin', hallSkins.length, 1),
      hair: hallHairs.contains(j['hair']) ? j['hair'] as String : 'short',
      hairColor: idx('hairColor', hallHairColors.length, 0),
      eyes: (j['eyes'] as String?) ?? (boy ? 'sharp' : 'sparkle'),
      eyeColor: idx('eyeColor', hallEyeColors.length, 0),
      blush: (j['blush'] as bool?) ?? !boy,
      brows: (j['brows'] as String?) ?? (boy ? 'thick' : 'thin'),
      mouth: (j['mouth'] as String?) ?? 'smile',
      face: (j['face'] as String?) ?? (boy ? 'strong' : 'soft'),
      beard: (j['beard'] as String?) ?? 'none',
      top: (j['top'] as String?) ?? 'hoodie',
      topColor: idx('topColor', hallTopColors.length, 1),
      accessories: {for (final a in (j['accessories'] as List? ?? const [])) a as String},
      boy: boy,
      reward: hallRewards.any((r) => r.id == j['reward']) ? j['reward'] as String : '',
    );
  }

  /// Until the character builder ships, everybody starts as this.
  static const fallback = HallAvatar();
}

/// A whole `<svg>` for [a]. With [silhouette] set, every part is that one
/// colour (the far-away figures in other windows).
String hallAvatarSvg(HallAvatar a, {String? silhouette, String viewBox = '-60 -176 120 172'}) {
  final defs = silhouette != null
      ? ''
      : '<defs><clipPath id="faceclip"><path d="$_faceSoft"/></clipPath>'
          '<linearGradient id="iris" x1="0" y1="0" x2="0" y2="1">'
          '<stop offset="0" stop-color="${_darken(hallEyeColors[a.eyeColor], .45)}"/>'
          '<stop offset=".55" stop-color="${hallEyeColors[a.eyeColor]}"/>'
          '<stop offset="1" stop-color="${_lighten(hallEyeColors[a.eyeColor], .55)}"/>'
          '</linearGradient></defs>';
  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="$viewBox">$defs${_avatar(a, silhouette)}</svg>';
}

const _lash = '#2A2230';
const _faceSoft = 'M-32 -106 C-33 -142 33 -142 32 -106 C32 -86 20 -68 0 -64 C-20 -68 -32 -86 -32 -106Z';
const _faceStrong = 'M-32 -106 C-33 -142 33 -142 32 -106 L31.5 -88 C30 -75 18 -64.5 0 -63.5 C-18 -64.5 -30 -75 -31.5 -88Z';

String _n(num v) {
  final s = v.toStringAsFixed(2);
  return s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
}

int _ch(String hex, int i) => int.parse(hex.substring(1 + i * 2, 3 + i * 2), radix: 16);
String _hex(Iterable<int> c) => '#${c.map((v) => v.clamp(0, 255).toRadixString(16).padLeft(2, '0')).join()}';
String _darken(String hex, [double k = .72]) => _hex([for (var i = 0; i < 3; i++) (_ch(hex, i) * k).round()]);
String _lighten(String hex, [double k = .4]) =>
    _hex([for (var i = 0; i < 3; i++) (_ch(hex, i) + (255 - _ch(hex, i)) * k).round()]);

String _eye(double x, HallAvatar c) {
  final s = x < 0 ? -1 : 1;
  var st = c.eyes == 'wink' ? (x > 0 ? 'happy' : 'sparkle') : c.eyes;
  if (c.boy) st = switch (st) { 'sparkle' => 'sharp', 'calm' => 'focus', _ => st };
  final pupil = _darken(hallEyeColors[c.eyeColor], .3);
  if (st == 'happy') {
    return '<path d="M${_n(x - 8)} -88 Q${_n(x)} -99 ${_n(x + 8)} -88" stroke="$_lash" stroke-width="3" fill="none" stroke-linecap="round"/>';
  }
  if (st == 'sharp' || st == 'focus') {
    final f = st == 'focus';
    final cy = (f ? -88.0 : -89.0) + (c.boy ? .8 : 0), ry = (f ? 5.6 : 7.0) - (c.boy ? .9 : 0), t = cy - ry;
    return '<ellipse cx="${_n(x)}" cy="${_n(cy)}" rx="8.4" ry="${_n(ry)}" fill="#fff"/>'
        '<ellipse cx="${_n(x - s * .6)}" cy="${_n(cy + .6)}" rx="5.6" ry="${_n(ry - .4)}" fill="url(#iris)"/>'
        '<ellipse cx="${_n(x - s * .6)}" cy="${_n(cy + 1)}" rx="2.6" ry="${_n(ry - 2.6)}" fill="$pupil"/>'
        '<circle cx="${_n(x - 2)}" cy="${_n(cy - 2.4)}" r="1.8" fill="#fff"/>'
        '<path d="M${_n(x - s * 8)} ${_n(t + 3.2)} Q${_n(x)} ${_n(t - (f ? .4 : 1.2))} ${_n(x + s * 9.5)} ${_n(t + 1.4)}" stroke="$_lash" stroke-width="3.2" fill="none" stroke-linecap="round"/>'
        '<path d="M${_n(x - 4)} ${_n(cy + ry + .4)} Q${_n(x + s)} ${_n(cy + ry + 1.2)} ${_n(x + s * 6)} ${_n(cy + ry - .6)}" stroke="$_lash" stroke-width="1" opacity=".4" fill="none"/>';
  }
  final calm = st == 'calm';
  final cy = calm ? -87.0 : -90.0, ry = calm ? 7.0 : 10.0, top = cy - ry + 1;
  return '<ellipse cx="${_n(x)}" cy="${_n(cy)}" rx="8" ry="${_n(ry)}" fill="#fff"/>'
      '<ellipse cx="${_n(x)}" cy="${_n(cy + 1)}" rx="6.6" ry="${_n(ry - 1)}" fill="url(#iris)"/>'
      '<ellipse cx="${_n(x)}" cy="${_n(cy + 2)}" rx="3" ry="${calm ? 3.6 : 4.8}" fill="$pupil"/>'
      '<circle cx="${_n(x - 2.6)}" cy="${_n(cy - 3.6)}" r="${calm ? 2.2 : 2.9}" fill="#fff"/>'
      '<circle cx="${_n(x + 2.8)}" cy="${_n(cy + 4.4)}" r="1.3" fill="#fff" opacity=".9"/>'
      '<path d="M${_n(x - s * 7.5)} ${_n(top + 3)} Q${_n(x + s * 1.5)} ${_n(top - (calm ? 1.5 : 3))} ${_n(x + s * 8.5)} ${_n(top + 2)}" stroke="$_lash" stroke-width="2.8" fill="none" stroke-linecap="round"/>'
      '<path d="M${_n(x + s * 8.2)} ${_n(top + 2)} q${_n(s * 3)} 0 ${_n(s * 4.4)} 2.6" stroke="$_lash" stroke-width="2.2" fill="none" stroke-linecap="round"/>'
      '<path d="M${_n(x - 4.5)} ${_n(cy + ry + .6)} Q${_n(x)} ${_n(cy + ry + 1.4)} ${_n(x + 4.5)} ${_n(cy + ry + .6)}" stroke="$_lash" stroke-width="1" opacity=".45" fill="none"/>';
}

const _bangs = {
  'long': 'M-37 -96 C-42 -152 42 -152 37 -96 L33 -92 L30 -108 L24 -96 L18 -114 L12 -99 L4 -116 L-2 -101 L-10 -116 L-16 -99 L-22 -112 L-28 -94 L-31 -106 L-37 -88 Z',
  'blunt': 'M-37 -96 C-42 -152 42 -152 37 -96 L34 -102 L28 -100 L22 -107 L14 -102 L6 -108 L-2 -102 L-10 -108 L-18 -102 L-26 -107 L-32 -100 L-37 -98Z',
  'swept': 'M-37 -96 C-42 -152 42 -152 37 -96 L33 -104 L28 -96 L24 -112 C12 -112 -4 -106 -18 -96 L-14 -108 C-22 -104 -28 -98 -32 -90 L-37 -86Z',
  'spiky': 'M-36 -96 L-42 -122 L-32 -122 L-35 -142 L-21 -134 L-15 -154 L-3 -141 L8 -157 L14 -140 L28 -148 L28 -132 L41 -130 L36 -96 L34 -108 L28 -100 L24 -114 L16 -102 L10 -118 L2 -104 L-6 -118 L-12 -102 L-20 -114 L-26 -100 L-32 -110Z',
  'wolf': 'M-37 -96 C-42 -152 42 -152 37 -96 L35 -86 L30 -104 L26 -92 L20 -112 L14 -94 L6 -112 L0 -96 L-6 -112 L-14 -94 L-20 -112 L-26 -92 L-30 -104 L-35 -84Z',
  'boy': 'M-36 -98 C-41 -150 41 -150 36 -98 L33 -104 L28 -111 L22 -106 L16 -115 L9 -108 L2 -117 L-5 -110 L-12 -117 L-18 -110 L-25 -115 L-30 -106 L-36 -100Z',
  'side': 'M-37 -98 C-42 -152 42 -152 37 -98 L35 -108 C31 -114 25 -118 17 -120 L12 -113 C2 -118 -12 -118 -24 -112 L-31 -102 L-37 -96Z',
  'buzz': 'M-34 -100 C-37 -149 37 -149 34 -100 L32 -106 C30 -113 22 -117 14 -117 C6 -119 -6 -119 -14 -117 C-22 -117 -30 -113 -32 -106Z',
};
const _back = {
  'long': 'M-40 -104 C-48 -158 48 -158 40 -104 L46 -32 L38 -40 L34 -26 L24 -36 L0 -30 L-24 -36 L-34 -26 L-38 -40 L-46 -32 Z',
  'wavy': 'M-40 -104 C-48 -158 48 -158 40 -104 Q51 -88 42 -74 Q53 -58 42 -42 Q47 -28 34 -24 L-34 -24 Q-47 -28 -42 -42 Q-53 -58 -42 -74 Q-51 -88 -40 -104Z',
  'bob': 'M-40 -104 C-48 -158 48 -158 40 -104 L42 -64 L34 -70 L28 -60 L-28 -60 L-34 -70 L-42 -64Z',
  'cap': 'M-39 -104 C-47 -158 47 -158 39 -104 L38 -82 L-38 -82Z',
  'wolf': 'M-40 -104 C-48 -158 48 -158 40 -104 L43 -68 L35 -74 L30 -60 L18 -70 L0 -64 L-18 -70 L-30 -60 L-35 -74 L-43 -68Z',
  'nape': 'M-38 -104 C-46 -156 46 -156 38 -104 L37 -86 L-37 -86Z',
};
String _side(int len) =>
    'M-37 -100 L-41 $len L-35 ${len + 8} L-31 ${len - 2} L-29 -96Z M37 -100 L41 $len L35 ${len + 8} L31 ${len - 2} L29 -96Z';

({String? back, String front, String? side, String? extra}) _hairParts(String h) => switch (h) {
      'long' => (back: _back['long'], front: _bangs['long']!, side: _side(-58), extra: null),
      'wavy' => (back: _back['wavy'], front: _bangs['swept']!, side: _side(-62), extra: null),
      'twin' => (back: _back['cap'], front: _bangs['long']!, side: _side(-70), extra: 'twin'),
      'pony' => (back: _back['cap'], front: _bangs['swept']!, side: _side(-74), extra: 'pony'),
      'bob' => (back: _back['bob'], front: _bangs['blunt']!, side: _side(-70), extra: null),
      'bun' => (back: _back['cap'], front: _bangs['blunt']!, side: null, extra: 'bun'),
      'wolf' => (back: _back['wolf'], front: _bangs['wolf']!, side: null, extra: null),
      'spiky' => (back: _back['cap'], front: _bangs['spiky']!, side: null, extra: null),
      'ahoge' => (back: _back['cap'], front: _bangs['wolf']!, side: null, extra: 'ahoge'),
      'side' => (back: _back['nape'], front: _bangs['side']!, side: null, extra: 'part'),
      'buzz' => (back: null, front: _bangs['buzz']!, side: null, extra: null),
      'curly' => (back: _back['nape'], front: _bangs['buzz']!, side: null, extra: 'curls'),
      _ => (back: _back['nape'], front: _bangs['boy']!, side: null, extra: null), // short
    };

String _avatar(HallAvatar c, String? sil) {
  String f(String k) => sil ?? k;
  final skin = hallSkins[c.skin], hc = hallHairColors[c.hairColor], tc = hallTopColors[c.topColor];
  final hd = _darken(hc, .8), acc = c.accessories, strong = c.face == 'strong';
  final h = _hairParts(c.hair);
  final g = StringBuffer();
  if (h.extra == 'twin') {
    g.write('<path d="M-34 -124 C-66 -120 -70 -66 -56 -30 L-50 -46 L-46 -28 C-40 -66 -40 -102 -30 -114Z M34 -124 C66 -120 70 -66 56 -30 L50 -46 L46 -28 C40 -66 40 -102 30 -114Z" fill="${f(hd)}"/>');
  }
  if (h.extra == 'pony') g.write('<path d="M16 -142 C60 -152 64 -94 50 -50 L45 -66 L38 -50 C48 -90 38 -122 12 -130Z" fill="${f(hd)}"/>');
  if (h.extra == 'bun') g.write('<circle cx="0" cy="-152" r="15" fill="${f(hd)}"/>');
  if (h.back != null) g.write('<path d="${h.back}" fill="${f(hd)}"/>');
  g.write(c.boy
      ? '<path d="M-55 0 C-55 -38 -36 -54 0 -54 C36 -54 55 -38 55 0 Z" fill="${f(tc)}"/>'
      : '<path d="M-46 0 C-46 -36 -28 -52 0 -52 C28 -52 46 -36 46 0 Z" fill="${f(tc)}"/>');
  if (sil == null) {
    switch (c.top) {
      case 'hoodie':
        g.write('<path d="M-24 -50 C-18 -34 18 -34 24 -50" stroke="${_darken(tc, .82)}" stroke-width="7" fill="none" stroke-linecap="round"/><path d="M-7 -38 v16 M7 -38 v16" stroke="${_lighten(tc, .6)}" stroke-width="2.2" stroke-linecap="round"/>');
      case 'sweater':
        g.write('<path d="M-12 -51 C-8 -43 8 -43 12 -51" stroke="${_darken(tc, .8)}" stroke-width="5" fill="none"/><path d="M-42 -16 H42" stroke="${_darken(tc, .88)}" stroke-width="4"/><path d="M-20 -30 l4 4 l4 -4 l4 4 l4 -4 l4 4 l4 -4 l4 4 l4 -4 l4 4" stroke="${_lighten(tc, .5)}" stroke-width="1.6" fill="none"/>');
      case 'shirt':
        g.write('<path d="M-13 -52 L-1 -38 L-6 -54Z M13 -52 L1 -38 L6 -54Z" fill="#fff"/><path d="M0 -40 l-3.5 4 l3.5 18 l3.5 -18z" fill="#C94B4B"/>');
      case 'jacket':
        g.write('<path d="M-15 -52 L-11 -43 L0 -39 L11 -43 L15 -52" stroke="${_darken(tc, .75)}" stroke-width="4" fill="none" stroke-linejoin="round"/><path d="M0 -39 V0" stroke="${_lighten(tc, .55)}" stroke-width="2"/><path d="M-40 -30 L-30 -12 M40 -30 L30 -12" stroke="${_lighten(tc, .35)}" stroke-width="3" stroke-linecap="round"/>');
      case 'tee':
        g.write('<path d="M-13 -51 C-8 -42 8 -42 13 -51" stroke="${_darken(tc, .8)}" stroke-width="3" fill="none"/>');
      case 'sailor':
        g.write('<path d="M-30 -50 L0 -22 L30 -50 L42 -26 L0 -10 L-42 -26Z" fill="#2E3A59"/><path d="M-36 -40 L0 -16 L36 -40" stroke="#fff" stroke-width="2" fill="none"/><path d="M0 -24 l-9 -5 v10z M0 -24 l9 -5 v10z" fill="#C94B4B"/><circle cx="0" cy="-24" r="2.6" fill="#A83A3A"/>');
    }
  }
  final neck = f(sil != null ? skin : _darken(skin, .9));
  g.write(c.boy
      ? '<rect x="-11" y="-70" width="22" height="20" rx="4" fill="$neck"/>'
      : strong
          ? '<rect x="-9.5" y="-68" width="19" height="18" rx="5" fill="$neck"/>'
          : '<rect x="-7" y="-68" width="14" height="18" rx="5" fill="$neck"/>');
  final ear = c.boy ? 6.2 : 5;
  g.write('<circle cx="-31" cy="-94" r="$ear" fill="${f(skin)}"/><circle cx="31" cy="-94" r="$ear" fill="${f(skin)}"/>');
  g.write('<path d="${strong ? _faceStrong : _faceSoft}" fill="${f(skin)}"/>');
  if (sil == null) {
    g.write('<g clip-path="url(#faceclip)"><path d="${h.front}" transform="translate(0,4)" fill="${_darken(skin, .86)}" opacity=".55"/></g>');
    if (acc.contains('earrings')) g.write('<circle cx="-31" cy="-87" r="2.4" fill="#E9C46A"/><circle cx="31" cy="-87" r="2.4" fill="#E9C46A"/>');
    g.write(_eye(-14, c));
    g.write(_eye(14, c));
    if (c.boy) {
      g.write('<path d="M-24 -74 C-16 -66 -8 -64 0 -64 C8 -64 16 -66 24 -74" stroke="${_darken(skin, .84)}" stroke-width="2" fill="none" opacity=".45"/>');
    }
    if (c.blush && !c.boy) {
      g.write('<ellipse cx="-20" cy="-78" rx="6" ry="3" fill="#F28A9B" opacity=".38"/><ellipse cx="20" cy="-78" rx="6" ry="3" fill="#F28A9B" opacity=".38"/>');
      for (final x in [-23, -20, -17, 17, 20, 23]) {
        g.write('<path d="M$x -80 l-1.6 3" stroke="#E8707F" stroke-width="1" opacity=".7"/>');
      }
    }
    g.write(c.boy
        ? '<path d="M1.2 -86 L-1 -80.5 L2 -80" stroke="${_darken(skin, .66)}" stroke-width="1.4" fill="none" stroke-linecap="round" stroke-linejoin="round"/>'
        : '<path d="M.6 -81 l-1 2" stroke="${_darken(skin, .7)}" stroke-width="1.2" stroke-linecap="round"/>');
    final bh = _darken(hc, .85);
    final must = '<path d="M-9.5 -76.6 Q-5 -81 0 -78.6 Q5 -81 9.5 -76.6 Q5 -77.8 0 -76.4 Q-5 -77.8 -9.5 -76.6Z" fill="$bh"/>';
    switch (c.beard) {
      case 'stubble':
        g.write('<path d="M-30.5 -92 C-30 -76 -19 -64.5 0 -63 C19 -64.5 30 -76 30.5 -92 C27 -83 21 -78.5 14 -79.5 C8 -76 -8 -76 -14 -79.5 C-21 -78.5 -27 -83 -30.5 -92Z" fill="$bh" opacity=".28"/><path d="M-9 -77 Q0 -80 9 -77" stroke="$bh" stroke-width="2.6" opacity=".3" fill="none" stroke-linecap="round"/>');
      case 'mustache':
        g.write(must);
      case 'goatee':
        g.write('$must<path d="M-7.5 -70.5 C-8 -61 8 -61 7.5 -70.5 C4.5 -67.5 -4.5 -67.5 -7.5 -70.5Z" fill="$bh"/>');
      case 'beard':
        g.write('<path d="M-31.5 -96 C-31.5 -74 -20 -59 0 -57 C20 -59 31.5 -74 31.5 -96 C28 -86 21 -80.5 14 -81 C9 -75.5 -9 -75.5 -14 -81 C-21 -80.5 -28 -86 -31.5 -96Z" fill="$bh"/>$must');
    }
    final mo = c.eyes == 'happy' && c.mouth == 'smile' ? 'grin' : c.mouth;
    g.write(switch (mo) {
      'grin' => '<path d="M-5 -74 Q0 -66 5 -74Z" fill="#9B4A4A"/><path d="M-3 -70 Q0 -68 3 -70" stroke="#E77777" stroke-width="1.6" fill="none"/>',
      'smirk' => '<path d="M-4 -73 Q1 -71.5 5.5 -75.5" stroke="#9B4A4A" stroke-width="1.8" fill="none" stroke-linecap="round"/>',
      'calm' => '<path d="M-3.2 -73.2 Q0 -72.6 3.2 -73.2" stroke="#9B4A4A" stroke-width="1.8" fill="none" stroke-linecap="round"/>',
      _ => c.boy
          ? '<path d="M-6 -73 Q0 -70.6 6 -73" stroke="#8A4545" stroke-width="2" fill="none" stroke-linecap="round"/>'
          : '<path d="M-4.5 -73.5 Q0 -70 4.5 -73.5" stroke="#9B4A4A" stroke-width="1.8" fill="none" stroke-linecap="round"/>',
    });
  }
  if (sil != null && c.beard == 'beard') g.write('<path d="M-31.5 -96 C-31.5 -74 -20 -59 0 -57 C20 -59 31.5 -74 31.5 -96Z" fill="$sil"/>');
  if (h.side != null) g.write('<path d="${h.side}" fill="${f(hc)}"/>');
  g.write('<path d="${h.front}" fill="${f(hc)}"/>');
  if (h.extra == 'curls') {
    for (final (x, y, r) in const [(-26, -118, 10), (-14, -128, 11), (0, -132, 11), (14, -128, 11), (26, -118, 10), (-31, -104, 8), (31, -104, 8), (-6, -120, 9), (8, -121, 9)]) {
      g.write('<circle cx="$x" cy="$y" r="$r" fill="${f(hc)}"/>');
    }
  }
  if (h.extra == 'part' && sil == null) g.write('<path d="M12 -113 C14 -124 16 -132 14 -140" stroke="${_darken(hc, .75)}" stroke-width="1.6" fill="none" opacity=".7"/>');
  if (h.extra == 'ahoge') g.write('<path d="M2 -144 C4 -166 22 -168 18 -154 C14 -160 8 -158 6 -144Z" fill="${f(hc)}"/>');
  if (sil == null) {
    g.write('<path d="M-25 -128 Q-14 -136 -4 -132 M4 -133 Q14 -136 25 -128" stroke="${_lighten(hc, .55)}" stroke-width="${c.boy ? 2.4 : 3.4}" fill="none" stroke-linecap="round" opacity="${c.boy ? .35 : .75}"/>');
    g.write('<path d="M-10 -142 L-14 -118 M12 -142 L16 -120" stroke="${_darken(hc, .85)}" stroke-width="1.2" opacity=".5"/>');
    if (c.boy) {
      final bc = _darken(hc, .55), w = c.brows == 'thick' ? 4.2 : 3;
      g.write('<path d="M-5 -102.5 L-12 -104.5 L-20 -103.5" stroke="$bc" stroke-width="$w" fill="none" stroke-linecap="round" stroke-linejoin="round"/><path d="M5 -102.5 L12 -104.5 L20 -103.5" stroke="$bc" stroke-width="$w" fill="none" stroke-linecap="round" stroke-linejoin="round"/>');
    } else if (c.brows == 'thick') {
      final bc = _darken(hc, .62);
      g.write('<path d="M-6 -105 Q-12 -108.5 -19 -106.5" stroke="$bc" stroke-width="3.4" fill="none" stroke-linecap="round"/><path d="M6 -105 Q12 -108.5 19 -106.5" stroke="$bc" stroke-width="3.4" fill="none" stroke-linecap="round"/>');
    }
    if (h.extra == 'twin') g.write('<circle cx="-34" cy="-124" r="4.5" fill="#F4A7B9"/><circle cx="34" cy="-124" r="4.5" fill="#F4A7B9"/>');
    if (acc.contains('bow')) g.write('<g transform="translate(24,-136) rotate(18)"><path d="M0 0 L-12 -8 L-12 8Z M0 0 L12 -8 L12 8Z" fill="#E85D75"/><circle r="3.4" fill="#C94B62"/></g>');
    if (acc.contains('glasses')) {
      g.write('<rect x="-24" y="-99" width="19" height="16" rx="6" stroke="#3A2E3A" stroke-width="1.8" fill="#ffffff" fill-opacity=".1"/><rect x="5" y="-99" width="19" height="16" rx="6" stroke="#3A2E3A" stroke-width="1.8" fill="#ffffff" fill-opacity=".1"/><path d="M-5 -92 h10" stroke="#3A2E3A" stroke-width="1.8"/>');
    }
  }
  if (acc.contains('cap')) {
    final cc = sil ?? '#3D4A6B';
    g.write('<path d="M-36 -114 C-37 -156 37 -156 36 -114 C24 -120 -24 -120 -36 -114Z" fill="$cc"/>');
    if (sil == null) {
      g.write('<path d="M-8 -119 C-4 -122 4 -122 8 -119" stroke="${_lighten(cc, .4)}" stroke-width="3" fill="none"/><circle cx="0" cy="-151" r="2.6" fill="${_lighten(cc, .3)}"/><path d="M-20 -140 Q0 -149 20 -140" stroke="${_lighten(cc, .25)}" stroke-width="1.4" fill="none"/>');
    }
  }
  final gold = c.reward == 'goldphones';
  final cat = acc.contains('catphones') && !gold;
  if (gold) {
    final band = sil ?? '#D9A53A', cup = sil ?? '#F2CB5B';
    g.write('<path d="M-37 -96 C-42 -160 42 -160 37 -96" stroke="$band" stroke-width="6.5" fill="none" stroke-linecap="round"/>');
    g.write('<rect x="-46" y="-109" width="14" height="27" rx="7" fill="$cup"/><rect x="32" y="-109" width="14" height="27" rx="7" fill="$cup"/>');
    if (sil == null) g.write('<circle cx="-39" cy="-95.5" r="3" fill="#FFF6D8"/><circle cx="39" cy="-95.5" r="3" fill="#FFF6D8"/>');
  } else if (acc.contains('headphones') || cat) {
    final band = sil ?? (cat ? '#F2C4D0' : '#3A3D52'), cup = sil ?? (cat ? '#FFF1F4' : '#E9E6EF');
    if (cat) {
      g.write('<path d="M-30 -136 L-34 -160 L-16 -146Z M30 -136 L34 -160 L16 -146Z" fill="$band"/>');
      if (sil == null) g.write('<path d="M-29 -140 L-31 -153 L-21 -146Z M29 -140 L31 -153 L21 -146Z" fill="#E88AA2"/>');
    }
    g.write('<path d="M-37 -96 C-42 -160 42 -160 37 -96" stroke="$band" stroke-width="6" fill="none" stroke-linecap="round"/>');
    g.write('<rect x="-45" y="-108" width="13" height="25" rx="6.5" fill="$cup"/><rect x="32" y="-108" width="13" height="25" rx="6.5" fill="$cup"/>');
    if (sil == null && cat) g.write('<circle cx="-38.5" cy="-95.5" r="3" fill="#F2A7B9"/><circle cx="38.5" cy="-95.5" r="3" fill="#F2A7B9"/>');
  }
  g.write(_reward(c.reward, sil));
  return g.toString();
}

String _reward(String id, String? sil) {
  String f(String k) => sil ?? k;
  switch (id) {
    case 'beanie':
      return '<path d="M-35 -112 C-37 -160 37 -160 35 -112 Z" fill="${f('#D9654B')}"/><rect x="-37" y="-122" width="74" height="13" rx="6.5" fill="${f('#B84E38')}"/>'
          '${sil == null ? '<path d="M-28 -120 v9 M-18 -121 v10 M-8 -121 v10 M2 -121 v10 M12 -121 v10 M22 -121 v10 M30 -120 v9" stroke="#9E412E" stroke-width="1.4"/>' : ''}'
          '<circle cx="0" cy="-158" r="8" fill="${f('#F3E6D3')}"/>';
    case 'scarf':
      return '<path d="M-25 -62 C-10 -52 10 -52 25 -62 L27 -50 C10 -38 -10 -38 -27 -50Z" fill="${f('#C94B4B')}"/><path d="M8 -46 L13 -20 L22 -22 L18 -48Z" fill="${f('#B23F3F')}"/>'
          '${sil == null ? '<path d="M-20 -55 L-16 -44 M-6 -51 L-4 -41 M8 -51 L6 -41 M20 -55 L16 -44" stroke="#F3E6D3" stroke-width="2.2" opacity=".8"/>' : ''}';
    case 'star':
      return '<path transform="translate(-24,-128) scale(1.1)" d="M0 -9 L2.6 -2.8 L9 -2.8 L3.8 1.2 L5.8 7.6 L0 3.8 L-5.8 7.6 L-3.8 1.2 L-9 -2.8 L-2.6 -2.8Z" fill="${f('#F5C842')}" stroke="${f('#D9A53A')}" stroke-width="1"/>';
    case 'gradcap':
      return '<path d="M-26 -140 v12 C-12 -120 12 -120 26 -128 v-12" fill="${f('#2A2D3E')}"/><path d="M-44 -142 L0 -158 L44 -142 L0 -126Z" fill="${f('#23263A')}"/>'
          '<path d="M0 -142 L30 -136 L30 -116" stroke="${f('#E9B949')}" stroke-width="2.2" fill="none"/><circle cx="30" cy="-114" r="3.4" fill="${f('#E9B949')}"/>';
  }
  return '';
}
