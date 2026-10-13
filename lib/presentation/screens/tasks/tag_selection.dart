import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/plan_widgets.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/presentation/widgets/re_text_field.dart';
import 'package:simo_learn/utils/_utils.dart';

/// A task's tags, as quick add and the full task forms pick them.
///
/// There are none to show until the task has a title: then [suggest] asks
/// the server which tags fit it, once typing pauses, and those come already
/// selected. Each new title asks again. The user can turn any tag off, and
/// add tags of their own, which stay whatever the title becomes.
class TagSelection extends ChangeNotifier {
  TagSelection({
    this.suggest,
    this.catalog = const [],
    Iterable<String> initial = const [],
    String initialTitle = '',
  })  : _extra = _unique(initial),
        _title = initialTitle.trim();

  final Future<List<String>> Function(String title)? suggest;

  /// Every known tag, offered as the user types one of their own.
  final List<String> catalog;

  static const Duration _delay = Duration(milliseconds: 450);
  static const int _maxSuggested = 8;
  static const int _maxMatches = 6;

  /// The server's tags for the current title.
  List<String> _suggested = const [];

  /// Tags not suggested for this title: typed in, or already on the task.
  final List<String> _extra;

  /// Tags the user turned off.
  final Set<String> _off = {};

  /// A tag being typed but not added yet; it still counts when the task is
  /// saved.
  String _draft = '';

  String _title;
  bool _loading = false;
  Timer? _timer;
  int _request = 0;
  bool _disposed = false;

  bool get isLoading => _loading;
  bool get hasSuggestions => _suggested.isNotEmpty;

  /// Whether there is anything to show; otherwise a hint stands in.
  bool get showsTags => _title.isNotEmpty || _extra.isNotEmpty;

  /// Suggested tags first, then the user's own.
  List<String> get offered => _unique([..._suggested, ..._extra]);

  bool isSelected(String tag) => !_off.contains(tag);

  /// What the task is saved with.
  List<String> get selected {
    final draft = _draft.trim();
    return _unique([
      for (final tag in offered)
        if (isSelected(tag)) tag,
      if (draft.isNotEmpty) draft,
    ]);
  }

  String get draft => _draft;

  /// Known tags containing [query] that are not picked yet, those starting
  /// with it first.
  List<String> matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return const [];
    final picked = {
      for (final tag in offered)
        if (isSelected(tag)) tag,
    };
    final found = [
      for (final tag in _unique(catalog))
        if (!picked.contains(tag) && tag.toLowerCase().contains(needle)) tag,
    ];
    found.sort((a, b) {
      final aStarts = a.toLowerCase().startsWith(needle) ? 0 : 1;
      final bStarts = b.toLowerCase().startsWith(needle) ? 0 : 1;
      return aStarts - bStarts;
    });
    return found.take(_maxMatches).toList();
  }

  void titleChanged(String value) {
    final title = value.trim();
    if (title == _title) return;
    _title = title;
    _timer?.cancel();
    final request = ++_request;
    if (title.isEmpty || suggest == null) {
      _suggested = const [];
      _loading = false;
      notifyListeners();
      return;
    }
    // One request once typing pauses, not one per keystroke.
    _timer = Timer(_delay, () => _load(title, request));
    notifyListeners();
  }

  Future<void> _load(String title, int request) async {
    _loading = true;
    notifyListeners();
    List<String>? names;
    try {
      names = await suggest!(title);
    } catch (error) {
      debugPrint('Tag suggestions failed: $error');
    }
    // Disposed, or a newer title has been typed since.
    if (_disposed || request != _request) return;
    final next = names == null
        ? _suggested
        : _unique(names).take(_maxSuggested).toList();
    // A new title's tags all start selected; when the same tags come back
    // (a typo fixed, say), what the user turned off stays off.
    if (!listEquals(next, _suggested)) _off.removeAll(next);
    _suggested = next;
    _loading = false;
    notifyListeners();
  }

  void toggle(String tag) {
    if (!_off.remove(tag)) _off.add(tag);
    notifyListeners();
  }

  void draftChanged(String value) => _draft = value;

  /// Adds a tag of the user's own, or turns a listed one back on.
  void add(String value) {
    _draft = '';
    final tag = value.trim();
    if (tag.isNotEmpty) {
      if (!offered.contains(tag)) _extra.add(tag);
      _off.remove(tag);
    }
    notifyListeners();
  }

  /// Back to no tags, for the next task.
  void reset() {
    _extra.clear();
    _off.clear();
    _draft = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }

  static List<String> _unique(Iterable<String> names) {
    final seen = <String>{};
    return [
      for (final name in names.map((name) => name.trim()))
        if (name.isNotEmpty && seen.add(name)) name,
    ];
  }
}

/// The tags of a [TagSelection] as chips, with one to add a tag; a hint
/// while there is no title yet. Keys start with [keyPrefix].
///
/// New chips pop in one after another, the add chip opens into a field, and
/// while the server is asked, faint placeholders hold the tags' place.
class TagSelectionChips extends StatefulWidget {
  const TagSelectionChips({
    super.key,
    required this.selection,
    required this.keyPrefix,
  });

  final TagSelection selection;
  final String keyPrefix;

  @override
  State<TagSelectionChips> createState() => _TagSelectionChipsState();
}

class _TagSelectionChipsState extends State<TagSelectionChips> {
  bool _adding = false;
  final TextEditingController _input = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.selection.addListener(_onSelectionChanged);
    _inputFocus.addListener(() {
      if (!_inputFocus.hasFocus && _adding) _commit();
    });
  }

  @override
  void dispose() {
    widget.selection.removeListener(_onSelectionChanged);
    _input.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _onSelectionChanged() {
    // Reset or saved elsewhere: the half-typed tag went with it.
    if (_adding && widget.selection.draft.isEmpty && _input.text.isNotEmpty) {
      _input.clear();
      _adding = false;
    }
    if (mounted) setState(() {});
  }

  void _start() {
    setState(() => _adding = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _inputFocus.requestFocus();
    });
  }

  void _commit() {
    _add(_input.text);
  }

  void _add(String tag) {
    _input.clear();
    setState(() => _adding = false);
    widget.selection.add(tag);
  }

  @override
  Widget build(BuildContext context) {
    final selection = widget.selection;
    final prefix = widget.keyPrefix;
    final offered = selection.offered;
    final matches = _adding ? selection.matches(_input.text) : const <String>[];
    final waiting = selection.isLoading && offered.isEmpty;
    _revealMatches(matches.isNotEmpty);

    final Widget body;
    if (!selection.showsTags) {
      // Empty until there is a title: the full tag list is long and would
      // only get in the way.
      body = _Hint(key: ValueKey('$prefix-tags-hint'));
    } else {
      body = Column(
        key: const ValueKey('tags'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (var index = 0; index < offered.length; index++)
                _PopIn(
                  key: ValueKey('$prefix-pop-${offered[index]}'),
                  order: index,
                  child: _TagChip(
                    key: ValueKey('$prefix-tag-${offered[index]}'),
                    text: offered[index],
                    selected: selection.isSelected(offered[index]),
                    onTap: () => selection.toggle(offered[index]),
                  ),
                ),
              if (waiting) ...const [
                _Placeholder(width: 66),
                _Placeholder(width: 88),
              ],
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: _adding ? _inputField(prefix) : _addChip(prefix),
              ),
            ],
          ),
          // Laid out at once (the chips pop in on their own), so they can be
          // scrolled into view right away.
          if (matches.isNotEmpty)
            Padding(
              key: _matchesKey,
              padding: const EdgeInsets.only(top: 10),
              // Known tags matching what is typed, one tap to add.
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (var index = 0; index < matches.length; index++)
                    _PopIn(
                      key: ValueKey('$prefix-pop-match-${matches[index]}'),
                      order: index,
                      child: _MatchChip(
                        key: ValueKey('$prefix-tag-match-${matches[index]}'),
                        text: matches[index],
                        onTap: () => _add(matches[index]),
                      ),
                    ),
                ],
              ),
            ),
        ],
      );
    }

    // Pinned: some screens using it are not RTL themselves.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        layoutBuilder: (current, previous) => Stack(
          alignment: AlignmentDirectional.topStart,
          children: [...previous, if (current != null) current],
        ),
        child: body,
      ),
    );
  }

  final GlobalKey _matchesKey = GlobalKey();
  bool _hadMatches = false;

  /// Matches open under the field being typed in, maybe below the fold or
  /// behind a pinned footer; bring them into view when they first appear.
  void _revealMatches(bool hasMatches) {
    if (hasMatches && !_hadMatches) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = _matchesKey.currentContext;
        if (context == null || !mounted) return;
        Scrollable.ensureVisible(
          context,
          duration: reduceMotion(this.context)
              ? Duration.zero
              : const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
      });
    }
    _hadMatches = hasMatches;
  }

  Widget _addChip(String prefix) {
    return Semantics(
      button: true,
      label: 'تگ دیگر',
      child: GestureDetector(
        key: ValueKey('$prefix-tag-new'),
        behavior: HitTestBehavior.opaque,
        onTap: _start,
        child: const DashedBorder(
          child: SizedBox(
            height: 34,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 16, color: AppColors.gray),
                  SizedBox(width: 4),
                  ReText(
                    'تگ دیگر',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String prefix) {
    return Container(
      width: 150,
      height: 34,
      padding: const EdgeInsetsDirectional.only(start: 10, end: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: AppColors.primary,
          width: kFocusedFieldBorderWidth,
        ),
        boxShadow: kFocusedFieldShadow,
      ),
      child: Row(
        children: [
          const ReText(
            '#',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.gray,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              key: ValueKey('$prefix-tag-input'),
              controller: _input,
              focusNode: _inputFocus,
              textInputAction: TextInputAction.done,
              onChanged: (value) {
                widget.selection.draftChanged(value);
                setState(() {}); // the matches below follow the text
              },
              onSubmitted: (_) => _commit(),
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                fontFamily: AppFonts.iranSansVar,
                fontVariations: AppFonts.fontVariations(FontWeight.w700),
                fontSize: 12.5,
                color: AppColors.black1,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'نام تگ',
                hintStyle: TextStyle(
                  fontFamily: AppFonts.iranSansVar,
                  fontVariations: AppFonts.fontVariations(FontWeight.w500),
                  fontSize: 12.5,
                  color: AppColors.gray,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// What the tags will do once there is a title.
class _Hint extends StatelessWidget {
  const _Hint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: ReText(
              'با نوشتن عنوان، تگ‌های مناسب پیشنهاد و انتخاب می‌شوند.',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gray,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}

/// A faint pill holding a tag's place while the server is asked.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return _Breathing(
      child: Container(
        width: width,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.gray2,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}

/// Slowly fades its child in and out, for things that are waiting.
class _Breathing extends StatefulWidget {
  const _Breathing({required this.child});

  final Widget child;

  @override
  State<_Breathing> createState() => _BreathingState();
}

class _BreathingState extends State<_Breathing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
    lowerBound: 0.45,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _controller.value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _controller, child: widget.child);
  }
}

/// Pops its child in when it first appears, a beat after the ones before
/// it ([order]); never again for the same key.
class _PopIn extends StatefulWidget {
  const _PopIn({super.key, required this.order, required this.child});

  final int order;
  final Widget child;

  @override
  State<_PopIn> createState() => _PopInState();
}

class _PopInState extends State<_PopIn> with SingleTickerProviderStateMixin {
  static const int _runMs = 260;

  // The wait is part of the animation (no timer), so it ends with it.
  late final int _delayMs = 45 * widget.order.clamp(0, 6);
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _delayMs + _runMs),
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve:
        Interval(_delayMs / (_delayMs + _runMs), 1, curve: Curves.easeOutBack),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) _controller.value = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        final t = _curve.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.scale(scale: 0.82 + 0.18 * t, child: child),
        );
      },
      child: widget.child,
    );
  }
}

/// A quiet note beside the tags' heading: a breathing sparkle while the
/// server is asked, then where the tags came from.
class TagSuggestionStatus extends StatelessWidget {
  const TagSuggestionStatus({
    super.key,
    required this.selection,
    required this.keyPrefix,
  });

  final TagSelection selection;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: selection,
      builder: (context, _) {
        final Widget note;
        if (selection.isLoading) {
          note = Row(
            key: ValueKey('$keyPrefix-tags-loading'),
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            children: const [
              _Breathing(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 13,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 4),
              ReText(
                'در حال پیشنهاد…',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.gray,
              ),
            ],
          );
        } else if (selection.hasSuggestions) {
          note = const Row(
            key: ValueKey('suggested'),
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            children: [
              Icon(Icons.auto_awesome_rounded,
                  size: 13, color: AppColors.primary),
              SizedBox(width: 4),
              ReText(
                'پیشنهاد از روی عنوان',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.gray,
              ),
            ],
          );
        } else {
          note = const SizedBox.shrink(key: ValueKey('none'));
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: note,
        );
      },
    );
  }
}

/// A known tag offered while typing: lighter than a tag chip, with a plus.
class _MatchChip extends StatelessWidget {
  const _MatchChip({super.key, required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'افزودن تگ $text',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.gray1,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, size: 14, color: AppColors.gray),
              const SizedBox(width: 3),
              ReText(
                text,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.black1,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A tag: `#name` while off, a black pill with a check once picked; the mark
/// turns over and the pill settles with a small bounce.
class _TagChip extends StatelessWidget {
  const _TagChip({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = AppColors.black1;
    return Semantics(
      button: true,
      selected: selected,
      label: text,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: TweenAnimationBuilder<double>(
          // Re-runs on every toggle: a quick dip and back.
          key: ValueKey(selected),
          tween: Tween(begin: 0.92, end: 1),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: 34,
            padding: const EdgeInsetsDirectional.only(start: 10, end: 13),
            decoration: BoxDecoration(
              // Picked: a soft gray pill with a dark edge, light enough for a
              // row of tags.
              color: selected ? AppColors.gray1 : AppColors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: selected ? AppColors.black1 : AppColors.gray2,
                width: selected ? 1.2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) => RotationTransition(
                      turns: Tween(begin: 0.75, end: 1.0).animate(animation),
                      child: ScaleTransition(scale: animation, child: child),
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check_rounded,
                            key: ValueKey('check'),
                            size: 14,
                            color: AppColors.black1,
                          )
                        : const ReText(
                            '#',
                            key: ValueKey('hash'),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gray,
                          ),
                  ),
                ),
                const SizedBox(width: 4),
                ReText(
                  text,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
