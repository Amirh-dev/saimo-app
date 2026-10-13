import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/chat/index.dart';
import 'package:simo_learn/presentation/screens/consultants/active_counselor_store.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_repository.dart';
import 'package:simo_learn/presentation/screens/consultants/list_screen.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

/// The counselor button in the screens' headers. Without a counselor it is
/// a gold «انتخاب مشاور» pill that a soft light crosses now and then, and
/// opens the list of counselors; with one, it is the counselor's photo and
/// opens the chat.
class ConsultantHeaderButton extends StatefulWidget {
  const ConsultantHeaderButton({super.key});

  @override
  State<ConsultantHeaderButton> createState() => _ConsultantHeaderButtonState();
}

class _ConsultantHeaderButtonState extends State<ConsultantHeaderButton> {
  final ActiveCounselorStore _store = ActiveCounselorStore.instance;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh({bool force = false}) {
    _store.refresh(
      ConsultantRepository(context.read<GraphQLRepository>()),
      force: force,
    );
  }

  Future<void> _open() async {
    HapticFeedback.selectionClick();
    final hasCounselor = _store.counselor != null;
    await context.to(
      hasCounselor ? const ChatScreen() : const ConsultantListScreen(),
    );
    // A counselor may have been bought, or changed, on the way.
    if (mounted) _refresh(force: true);
  }

  void _setPressed(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final counselor = _store.counselor;
        final Widget child;
        final String label;
        if (!_store.isKnown) {
          child = const _Placeholder(key: ValueKey('consultant-unknown'));
          label = 'مشاور';
        } else if (counselor != null) {
          child = _CounselorAvatar(
            key: const ValueKey('consultant-avatar'),
            counselor: counselor,
          );
          final name = counselor.name ?? counselor.username;
          label = name == null ? 'گفتگو با مشاور' : 'گفتگو با مشاور، $name';
        } else {
          child =
              const _ChooseCounselorPill(key: ValueKey('consultant-choose'));
          label = 'انتخاب مشاور';
        }

        return Semantics(
          button: true,
          label: label,
          excludeSemantics: true,
          child: GestureDetector(
            key: const ValueKey('consultant-header-button'),
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            onTap: _open,
            child: SizedBox(
              height: 48,
              child: Center(
                child: AnimatedScale(
                  scale: _pressed ? 0.94 : 1,
                  duration: Duration(milliseconds: _pressed ? 90 : 240),
                  curve: _pressed ? Curves.easeOut : Curves.easeOutBack,
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 320),
                    curve: AppMotion.settle,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween(begin: 0.9, end: 1.0).animate(animation),
                          child: child,
                        ),
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

const double _avatarSize = 38;

/// Holds the place, quietly, until the first answer.
class _Placeholder extends StatelessWidget {
  const _Placeholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: const BoxDecoration(
        color: AppColors.gray2,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _CounselorAvatar extends StatelessWidget {
  const _CounselorAvatar({super.key, required this.counselor});

  final ActiveCounselor counselor;

  @override
  Widget build(BuildContext context) {
    final avatar = counselor.avatar;
    final hasPhoto = avatar.startsWith('http');
    final name = (counselor.name ?? counselor.username ?? '').trim();
    final initial = name.isEmpty ? null : name.characters.first;

    final fallback = Container(
      color: AppColors.gray1,
      alignment: Alignment.center,
      child: initial == null
          ? const Icon(SolarIconsOutline.userSpeakRounded,
              size: 20, color: AppColors.black1)
          : ReText(
              initial,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.black1,
            ),
    );

    return Container(
      width: _avatarSize,
      height: _avatarSize,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gray2),
      ),
      child: ClipOval(
        child: hasPhoto
            ? Image.network(
                avatar,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : fallback,
              )
            : fallback,
      ),
    );
  }
}

/// The gold pill shown until a counselor is chosen. Every few seconds a
/// faint band of light crosses it, enough to catch the eye without
/// nagging; it stays still when the system asks for less motion.
class _ChooseCounselorPill extends StatefulWidget {
  const _ChooseCounselorPill({super.key});

  @override
  State<_ChooseCounselorPill> createState() => _ChooseCounselorPillState();
}

class _ChooseCounselorPillState extends State<_ChooseCounselorPill>
    with SingleTickerProviderStateMixin {
  /// The light takes [_sweep] to cross, once every [_every]. Between sweeps
  /// nothing animates, so no frames are drawn for it.
  static const Duration _sweep = Duration(milliseconds: 1500);
  static const Duration _every = Duration(milliseconds: 5200);

  late final AnimationController _glint =
      AnimationController(vsync: this, duration: _sweep);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_every, (_) {
      if (!mounted || reduceMotion(context)) return;
      _glint.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pill = DecoratedBox(
      decoration: BoxDecoration(
        // Two close yellows, light on the reading side: gold without the
        // gloss or bevel of a classic button.
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [_goldLight, _goldDeep],
        ),
        borderRadius: BorderRadius.all(Radius.circular(100)),
      ),
      child: SizedBox(
        height: 36,
        child: Padding(
          padding: EdgeInsetsDirectional.only(start: 10, end: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(SolarIconsBold.userSpeakRounded,
                  size: 17, color: AppColors.black1),
              SizedBox(width: 6),
              ReText(
                'انتخاب مشاور',
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: AppColors.black1,
              ),
            ],
          ),
        ),
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      // The glow sits outside the clip that shapes the shine.
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: _goldDeep.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: AnimatedBuilder(
            animation: _glint,
            child: pill,
            builder: (context, child) {
              final t = _glint.value;
              if (!_glint.isAnimating || t <= 0 || t >= 1) return child!;
              return Stack(
                children: [
                  child!,
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            // Reads like the text: right to left.
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              AppColors.white.withValues(alpha: 0),
                              AppColors.white.withValues(alpha: 0.4),
                              AppColors.white.withValues(alpha: 0),
                            ],
                            stops: const [0.35, 0.5, 0.65],
                            transform: _Slide(
                              Curves.easeInOut.transform(t) * 2 - 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The pill's gold: two close, clean yellows. A brownish shade reads as
/// dirty, and more stops start to look like a classic metal button.
const Color _goldLight = Color(0xFFFFD45C);
const Color _goldDeep = Color(0xFFFFB81F);

/// Moves a gradient across its box: -1 fully before it, 1 fully past it.
class _Slide extends GradientTransform {
  const _Slide(this.offset);

  final double offset;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(-bounds.width * offset, 0, 0);
}
