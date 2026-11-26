import 'package:simo_learn/features/study_hall/hall_avatar.dart';

/// Ready characters the builder starts from (docs/design/study-hall/builder.html).
const hallBoyPresets = <HallAvatar>[
  HallAvatar(skin: 1, hair: 'short', hairColor: 0, eyes: 'sharp', brows: 'thick', mouth: 'smile', accessories: {'headphones'}, top: 'hoodie', topColor: 1),
  HallAvatar(skin: 2, hair: 'side', hairColor: 1, eyes: 'focus', eyeColor: 1, brows: 'thick', mouth: 'smirk', beard: 'stubble', accessories: {'glasses'}, top: 'shirt', topColor: 5),
  HallAvatar(skin: 0, hair: 'spiky', hairColor: 6, eyes: 'sharp', eyeColor: 2, brows: 'thick', mouth: 'grin', accessories: {}, top: 'jacket', topColor: 7),
  HallAvatar(skin: 3, hair: 'curly', hairColor: 0, eyes: 'sharp', brows: 'thick', mouth: 'smile', beard: 'goatee', accessories: {'cap'}, top: 'tee', topColor: 3),
  HallAvatar(skin: 1, hair: 'wolf', hairColor: 7, eyes: 'focus', eyeColor: 4, brows: 'thin', mouth: 'calm', accessories: {'headphones'}, top: 'jacket', topColor: 0),
  HallAvatar(skin: 2, hair: 'buzz', hairColor: 1, eyes: 'sharp', eyeColor: 1, brows: 'thick', mouth: 'grin', beard: 'beard', accessories: {}, top: 'sweater', topColor: 2),
  HallAvatar(skin: 0, hair: 'ahoge', hairColor: 3, eyes: 'focus', eyeColor: 3, brows: 'thick', mouth: 'smile', accessories: {'glasses'}, top: 'hoodie', topColor: 3),
  HallAvatar(skin: 4, hair: 'short', hairColor: 0, eyes: 'sharp', eyeColor: 1, brows: 'thick', mouth: 'smirk', beard: 'mustache', accessories: {'cap'}, top: 'jacket', topColor: 4),
  HallAvatar(skin: 1, hair: 'side', hairColor: 4, eyes: 'sharp', eyeColor: 2, brows: 'thick', mouth: 'smile', beard: 'stubble', accessories: {}, top: 'tee', topColor: 6),
];

const hallGirlPresets = <HallAvatar>[
  HallAvatar(boy: false, skin: 0, hair: 'long', hairColor: 5, eyes: 'sparkle', eyeColor: 4, blush: true, brows: 'thin', face: 'soft', accessories: {'headphones'}, top: 'hoodie', topColor: 5),
  HallAvatar(boy: false, skin: 2, hair: 'twin', hairColor: 4, eyes: 'happy', eyeColor: 1, blush: true, brows: 'thin', face: 'soft', accessories: {'bow'}, top: 'sweater', topColor: 5),
  HallAvatar(boy: false, skin: 3, hair: 'bob', hairColor: 1, eyes: 'sparkle', blush: true, brows: 'thin', face: 'soft', accessories: {'glasses', 'earrings'}, top: 'sweater', topColor: 6),
  HallAvatar(boy: false, skin: 1, hair: 'pony', hairColor: 0, eyes: 'calm', eyeColor: 2, blush: true, brows: 'thin', face: 'soft', accessories: {'headphones'}, top: 'jacket', topColor: 6),
  HallAvatar(boy: false, skin: 2, hair: 'pony', hairColor: 2, eyes: 'calm', eyeColor: 1, blush: true, brows: 'thin', face: 'soft', accessories: {'earrings'}, top: 'shirt', topColor: 2),
  HallAvatar(boy: false, skin: 4, hair: 'bun', hairColor: 0, eyes: 'sparkle', eyeColor: 3, blush: true, brows: 'thin', face: 'soft', accessories: {'headphones'}, top: 'hoodie', topColor: 4),
  HallAvatar(boy: false, skin: 0, hair: 'bob', hairColor: 4, eyes: 'wink', eyeColor: 3, blush: true, brows: 'thin', face: 'soft', accessories: {'bow'}, top: 'tee', topColor: 4),
  HallAvatar(boy: false, skin: 1, hair: 'wavy', hairColor: 3, eyes: 'happy', blush: true, brows: 'thin', face: 'soft', accessories: {'glasses'}, top: 'hoodie', topColor: 1),
  HallAvatar(boy: false, skin: 2, hair: 'wavy', hairColor: 5, eyes: 'sparkle', eyeColor: 1, blush: true, brows: 'thin', face: 'soft', accessories: {'earrings'}, top: 'jacket', topColor: 3),
];
