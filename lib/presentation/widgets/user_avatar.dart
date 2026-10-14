import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';

/// A person's picture. Without one, or while it loads or if it fails, a
/// quiet gray circle with the first letter of their name stands in; with no
/// name either, a simple person glyph.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.imageUrl,
    required this.size,
    this.name,
    this.borderRadius,
  });

  final String? imageUrl;
  final double size;
  final String? name;

  /// Rounds the corners by this much; a circle when null.
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    final placeholder = UserAvatarPlaceholder(name: name, size: size);
    final Widget image = url.startsWith('http')
        ? Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => placeholder,
            loadingBuilder: (_, child, progress) =>
                progress == null ? child : placeholder,
          )
        : placeholder;

    final radius = borderRadius;
    return SizedBox(
      width: size,
      height: size,
      child: radius == null
          ? ClipOval(child: image)
          : ClipRRect(borderRadius: BorderRadius.circular(radius), child: image),
    );
  }
}

/// What [UserAvatar] shows when there is no picture.
class UserAvatarPlaceholder extends StatelessWidget {
  const UserAvatarPlaceholder({super.key, this.name, required this.size});

  final String? name;
  final double size;

  /// The first letter of [name], or null when there is no name.
  static String? initialOf(String? name) {
    final trimmed = name?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed.characters.first;
  }

  @override
  Widget build(BuildContext context) {
    final initial = initialOf(name);
    return Container(
      key: const ValueKey('user-avatar-placeholder'),
      width: size,
      height: size,
      color: AppColors.gray2,
      alignment: Alignment.center,
      child: initial == null
          ? Icon(IconsaxPlusBold.user, size: size * 0.44, color: AppColors.gray)
          : ReText(
              initial,
              fontSize: size * 0.4,
              fontWeight: FontWeight.w800,
              color: AppColors.gray,
              textAlign: TextAlign.center,
            ),
    );
  }
}
