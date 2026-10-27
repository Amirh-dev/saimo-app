import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simo_learn/core/global/global_data_model.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/plan_widgets.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/presentation/widgets/re_text_field.dart';
import 'package:simo_learn/utils/_utils.dart';

/// Longest tag name the server accepts.
const int kMaxTagNameLength = 50;

const Map<String, String> _letterVariants = {
  'ي': 'ی', 'ك': 'ک',
  '٠': '۰', '١': '۱', '٢': '۲', '٣': '۳', '٤': '۴',
  '٥': '۵', '٦': '۶', '٧': '۷', '٨': '۸', '٩': '۹',
};

/// A tag name as the server stores it (its canonicalizeTagName): Arabic
/// letter and digit forms made Persian, lower case, single spaces. Names with
/// the same form are one tag there, so they are one chip here.
String canonicalTagName(String name) {
  final persian = name.split('').map((char) => _letterVariants[char] ?? char);
  return persian
      .join()
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .join(' ');
}

/// Common short words the server drops from a title before matching
/// (persianStopwords), so they never make a tag look named.
const Set<String> _stopwords = {
  'از', 'به', 'با', 'در', 'را', 'که', 'این', 'آن', 'برای', 'هم', 'تا', 'یا',
  'اگر', 'ولی', 'اما', 'است', 'بود', 'شد', 'شود', 'می', 'ها', 'های', 'و',
  'یک', 'همه', 'روی', 'بین', 'چون', 'پس',
};

/// Grade words, shared by every subject's courses: a title naming only a
/// grade says nothing about which course it is.
const Set<String> _gradeWords = {'دهم', 'یازدهم', 'دوازدهم'};

/// The shortest word that may match a longer one by its start ("ریاضی" for
/// "ریاضیات"), as on the server.
const int _minPrefixLength = 4;

/// [text] in words, as the server's tokenizeForTagSuggestion splits it:
/// Persian letter forms, a ZWNJ as a break, lower case, no one-letter words
/// or stopwords.
List<String> _words(String text) {
  final persian = text
      .split('')
      .map((char) => _letterVariants[char] ?? char)
      .join()
      .replaceAll('‌', ' ')
      .toLowerCase();
  final seen = <String>{};
  return [
    for (final word in persian.split(RegExp(r'[\s\p{P}]+', unicode: true)))
      if (word.runes.length >= 2 &&
          !_stopwords.contains(word) &&
          seen.add(word))
        word,
  ];
}

/// Whether two words are the same: equal, or one starts the other and is
/// long enough to say so.
bool _sameWord(String a, String b) {
  if (a == b) return true;
  final (shorter, longer) = a.runes.length <= b.runes.length ? (a, b) : (b, a);
  return shorter.runes.length >= _minPrefixLength && longer.startsWith(shorter);
}

/// A task's tags, as quick add and the full task forms pick them.
///
/// There are none to show until the task has a title: then [suggest] asks
/// the server which tags fit it, once typing pauses, and those and the
/// [catalog] tags related to the title are offered, most related first.
/// Only the ones the title names outright, by name or [aliases], come
/// selected, and only when there are a few; the rest wait for a tap, and the
/// form asks for a fuller title instead of guessing. Each new title asks
/// again. The user can turn any tag on or off, and add tags of their own;
/// those stay whatever the title becomes.
///
/// The known tags come from [readCatalog], read whenever they are needed:
/// they may load after the form opens. Without it, [catalog], [aliases] and
/// [children] stand in.
class TagSelection extends ChangeNotifier {
  TagSelection({
    this.suggest,
    List<String> catalog = const [],
    Map<String, List<String>> aliases = const {},
    Map<String, List<String>> children = const {},
    TagCatalog Function()? readCatalog,
    Iterable<String> initial = const [],
    Iterable<String> initialOff = const [],
    String initialTitle = '',
  })  : _readCatalog = readCatalog ??
            (() => (names: catalog, aliases: aliases, children: children)),
        _extra = _unique(initial),
        _title = initialTitle.trim() {
    // Tags the task already has that can no longer be saved (blocked).
    _off.addAll(_unique(initialOff));
  }

  final Future<List<String>> Function(String title)? suggest;

  /// Every known tag, offered as the user types one of their own; the other
  /// names of tags (a title or search naming one names the tag); and the
  /// tags under each main tag ("ریاضی دهم" under "ریاضی"), offered when a
  /// title names the main one.
  final TagCatalog Function() _readCatalog;

  static const Duration _delay = Duration(milliseconds: 450);
  static const Duration _searchDelay = Duration(milliseconds: 300);

  /// Most of the server's tags added below the known ones that match a tag
  /// being typed.
  static const int _maxSearchResults = 3;

  /// The server's tags for a tag being typed, and what was typed.
  List<String> _searchResults = const [];
  String _searchedFor = '';
  Timer? _searchTimer;
  int _searchRequest = 0;
  static const int _maxSuggested = 10;
  static const int _maxMatches = 6;

  /// Most tags a title gets selected by itself; one naming more is left to
  /// the user.
  static const int _maxNamed = 3;

  /// The tags offered for the current title, most related first.
  List<String> _suggested = const [];

  /// Offered tags the title names outright, selected by themselves.
  Set<String> _named = const {};

  /// Whether the title names a few tags outright (selected or not), few
  /// enough to select.
  bool _namesFew = false;

  /// The grade the title names when it names no tag ("یازدهم" alone).
  String? _bareGrade;

  /// Tags the user picked or typed in, or already on the task.
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

  /// Whether there is anything to show; otherwise a hint stands in.
  bool get showsTags => _title.isNotEmpty || _extra.isNotEmpty;

  /// Whether a title has been typed.
  bool get hasTitle => _title.isNotEmpty;

  /// Suggested tags first, then the user's own.
  List<String> get offered => _unique([..._suggested, ..._extra]);

  bool isSelected(String tag) =>
      !_off.contains(tag) && (_extra.contains(tag) || _named.contains(tag));

  /// Whether the server's answer for the title as it is now is in.
  bool get _settled => !_loading && !(_timer?.isActive ?? false);

  /// A suggested tag within one the title selected, to show what a fuller
  /// title looks like ("ریاضی دهم" for "ریاضی"); null when there is none,
  /// or the user has picked something narrower already.
  String? get fullerTitleExample {
    if (!_settled) return null;
    for (final tag in _suggested) {
      if (isSelected(tag)) continue;
      if (_named.any((named) => isSelected(named) && _isWithin(tag, named))) {
        return tag;
      }
    }
    return null;
  }

  /// Whether the title named no tag surely enough (or too many) to select
  /// any, though tags were suggested or it names a grade, and nothing is
  /// picked yet.
  bool get needsClearerTitle =>
      _settled &&
      (_suggested.isNotEmpty || _bareGrade != null) &&
      !_namesFew &&
      !offered.any(isSelected);

  /// The grade a title names without a lesson, for an example with one
  /// ("فیزیک یازدهم"); null otherwise.
  String? get bareGrade => needsClearerTitle ? _bareGrade : null;

  /// What the task is saved with.
  List<String> get selected {
    final draft = canonicalTagName(_draft);
    return _unique([
      for (final tag in offered)
        if (isSelected(tag)) tag,
      if (draft.isNotEmpty) draft,
    ]);
  }

  String get draft => _draft;

  /// Known tags not picked yet whose name, or one of their other names,
  /// contains [query] («خواندن» finds «مطالعه»), the closest first; then,
  /// once the server has answered for [query], its tags not among them.
  List<String> matches(String query) {
    final needle = canonicalTagName(query);
    if (needle.isEmpty) return const [];
    final catalog = _readCatalog();
    final picked = {
      for (final tag in offered)
        if (isSelected(tag)) tag,
    };
    List<String> names(String tag) =>
        [tag, ...?catalog.aliases[tag]?.map(canonicalTagName)];
    final found = [
      for (final tag in _unique(catalog.names))
        if (!picked.contains(tag) &&
            names(tag).any((name) => name.contains(needle)))
          tag,
    ];
    // A whole word first, then a word it starts, then inside a word: «دهم»
    // finds «فیزیک دهم» before «فیزیک یازدهم».
    int rank(String tag) {
      final all = names(tag);
      final words = [for (final name in all) ...name.split(' ')];
      if (all.any((name) => name.startsWith(needle)) ||
          words.contains(needle)) {
        return 0;
      }
      return words.any((word) => word.startsWith(needle)) ? 1 : 2;
    }

    // Catalog order among equals.
    final order = {for (final (i, tag) in found.indexed) tag: i};
    found.sort((a, b) {
      final byRank = rank(a) - rank(b);
      return byRank != 0 ? byRank : order[a]! - order[b]!;
    });
    final known = found.take(_maxMatches).toList();
    final fromServer = _searchedFor == needle
        ? [
            for (final tag in _searchResults)
              if (!picked.contains(tag) && !known.contains(tag)) tag,
          ].take(_maxSearchResults)
        : const <String>[];
    return [...known, ...fromServer];
  }

  void titleChanged(String value) {
    final title = value.trim();
    if (title == _title) return;
    _title = title;
    _timer?.cancel();
    final request = ++_request;
    if (title.isEmpty || suggest == null) {
      _suggested = const [];
      _named = const {};
      _namesFew = false;
      _bareGrade = null;
      _loading = false;
      notifyListeners();
      return;
    }
    // One request once typing pauses, not one per keystroke.
    _timer = Timer(_delay, () => _load(title, request));
    notifyListeners();
  }

  /// Asks about the title the selection started with right away, as when a
  /// form opens with one. With [select] false nothing is selected by itself:
  /// the tags it started with are the user's choice already.
  void suggestNow({bool select = true}) {
    if (_title.isEmpty || suggest == null) return;
    _timer?.cancel();
    _load(_title, ++_request, select: select);
  }

  Future<void> _load(String title, int request, {bool select = true}) async {
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
    if (names != null) {
      final terms = _words(title);
      final next = _related(terms, _unique(names));
      final named = [
        for (final tag in next)
          if (_isNamed(tag, terms)) tag,
      ];
      // Only the narrowest named tags are selected: «ریاضی» saved beside
      // «ریاضی دهم» would count the task twice under ریاضی. The broader one
      // stays on offer.
      final narrowest = [
        for (final tag in named)
          if (!named.any((other) => _isWithin(other, tag))) tag,
      ];
      final selected = select && narrowest.length <= _maxNamed
          ? narrowest.toSet()
          : const <String>{};
      // A new title's tags start afresh; when the same ones come back (a
      // typo fixed, say), what the user turned off stays off.
      if (!listEquals(next, _suggested) || !setEquals(selected, _named)) {
        _off.removeAll(next);
      }
      _suggested = next;
      _named = selected;
      _namesFew = narrowest.isNotEmpty && narrowest.length <= _maxNamed;
      _bareGrade =
          named.isEmpty ? terms.where(_gradeWords.contains).firstOrNull : null;
    }
    _loading = false;
    notifyListeners();
  }

  void toggle(String tag) {
    if (isSelected(tag)) {
      _off.add(tag);
    } else {
      _pick(tag);
    }
    notifyListeners();
  }

  /// Notes the tag being typed and, once typing pauses, asks [suggest] about
  /// it as about a title: the server knows tags by words it has learned go
  /// with them («انتگرال» for «حسابان»), not only by name.
  void draftChanged(String value) {
    _draft = value;
    _searchTimer?.cancel();
    final query = canonicalTagName(value);
    final request = ++_searchRequest;
    if (query.isEmpty || suggest == null) return;
    _searchTimer = Timer(_searchDelay, () async {
      List<String>? names;
      try {
        names = await suggest!(query);
      } catch (error) {
        debugPrint('Tag search failed: $error');
      }
      // Disposed, or more has been typed since.
      if (_disposed || request != _searchRequest || names == null) return;
      _searchedFor = query;
      _searchResults = _unique(names);
      notifyListeners();
    });
  }

  /// Adds a tag of the user's own, or turns a listed one on.
  void add(String value) {
    _draft = '';
    _searchTimer?.cancel();
    _searchRequest++;
    final tag = canonicalTagName(value);
    if (tag.isNotEmpty) _pick(tag);
    notifyListeners();
  }

  /// Turns [tag] on as the user's own, so it stays whatever the title
  /// becomes, and turns off the broader tags it stands within.
  void _pick(String tag) {
    _off.remove(tag);
    if (!_extra.contains(tag)) _extra.add(tag);
    for (final broader in offered) {
      if (isSelected(broader) && _isWithin(tag, broader)) _off.add(broader);
    }
  }

  /// Each name [tag] goes by, in words.
  List<List<String>> _forms(String tag) => [
        for (final name in [tag, ...?_readCatalog().aliases[tag]])
          if (_words(name).isNotEmpty) _words(name),
      ];

  /// Whether [terms] hold every word of one of [tag]'s names.
  bool _isNamed(String tag, List<String> terms) => _forms(tag).any((form) =>
      form.every((word) => terms.any((term) => _sameWord(term, word))));

  /// Whether [tag] has every word of one of [broader]'s names, and more
  /// ("ریاضی دهم" within "ریاضی").
  bool _isWithin(String tag, String broader) {
    final words = _words(tag);
    return tag != broader &&
        _forms(broader).any((form) =>
            form.length < words.length &&
            form.every((word) => words.any((other) => _sameWord(other, word))));
  }

  /// The server's tags for a title of [terms] and the known tags related to
  /// it, most related first, [_maxSuggested] at most: tags it names, then
  /// ones sharing a word with it or under a tag it names (its grade's
  /// before others'), then the server's guesses from past tasks, then ones
  /// sharing only its grade. Nothing related is left out for being only a
  /// little related; it just comes later.
  List<String> _related(List<String> terms, List<String> fromServer) {
    final grades = terms.where(_gradeWords.contains).toSet();
    final catalog = _readCatalog();
    final children = catalog.children;
    final candidates = _unique([...fromServer, ...catalog.names]);
    final named = {
      for (final tag in candidates)
        if (_isNamed(tag, terms)) tag,
    };
    int score(String tag) {
      final words = {for (final form in _forms(tag)) ...form};
      final shared =
          words.where((word) => terms.any((term) => _sameWord(term, word)));
      final tagGrades = words.where(_gradeWords.contains).toSet();
      var score = fromServer.contains(tag) ? 8 : 0;
      if (named.contains(tag)) score += 100;
      if (shared.any((word) => !_gradeWords.contains(word))) score += 20;
      if (named.any((main) => children[main]?.contains(tag) ?? false)) {
        score += 15;
      }
      if (grades.isNotEmpty && tagGrades.isNotEmpty) {
        score += tagGrades.any(grades.contains) ? 10 : -15;
      }
      return score;
    }

    final scored = [
      for (var index = 0; index < candidates.length; index++)
        (tag: candidates[index], score: score(candidates[index]), index: index),
    ]..retainWhere((entry) => entry.score > 0);
    // Server order, then the catalog's, among equals.
    scored.sort(
        (a, b) => a.score != b.score ? b.score - a.score : a.index - b.index);
    return [for (final entry in scored.take(_maxSuggested)) entry.tag];
  }

  /// Back to no tags, for the next task.
  void reset() {
    _extra.clear();
    _off.clear();
    _draft = '';
    _searchTimer?.cancel();
    _searchRequest++;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _searchTimer?.cancel();
    super.dispose();
  }

  static List<String> _unique(Iterable<String> names) {
    final seen = <String>{};
    return [
      for (final name in names.map(canonicalTagName))
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
      if (!mounted) return;
      _inputFocus.requestFocus();
      _dropdown.show();
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
                child:
                    _adding ? _inputField(prefix, matches) : _addChip(prefix),
              ),
            ],
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

  final OverlayPortalController _dropdown = OverlayPortalController();
  final LayerLink _fieldLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();

  /// Known tags matching what is typed, in a list hanging under the field,
  /// or over it when the keyboard leaves no room below; one tap adds one.
  Widget _dropdownFor(
      BuildContext context, String prefix, List<String> matches) {
    if (matches.isEmpty) return const SizedBox.shrink();
    const width = 240.0;
    const gap = 6.0;
    final height = math.min(
        matches.length * _MatchList.rowHeight + 12, _MatchList.maxHeight);
    var above = false;
    var alignRight = true;
    final box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.attached && box.hasSize) {
      final topLeft = box.localToGlobal(Offset.zero);
      final media = MediaQuery.of(context);
      final below = media.size.height -
          media.viewInsets.bottom -
          topLeft.dy -
          box.size.height;
      above = below < height + gap + 8 && topLeft.dy > below;
      // The field's right edge is where the list starts (RTL), unless that
      // would push it off the left of the screen.
      alignRight = topLeft.dx + box.size.width >= width + 16;
    }
    final x = alignRight ? 1.0 : -1.0;
    return Positioned(
      width: width,
      child: CompositedTransformFollower(
        link: _fieldLink,
        showWhenUnlinked: false,
        targetAnchor: Alignment(x, above ? -1 : 1),
        followerAnchor: Alignment(x, above ? 1 : -1),
        offset: Offset(0, above ? -gap : gap),
        // Part of the field: a tap here must not close it and save the
        // half-typed text.
        child: TextFieldTapRegion(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: _MatchList(prefix: prefix, matches: matches, onTap: _add),
          ),
        ),
      ),
    );
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

  Widget _inputField(String prefix, List<String> matches) {
    return OverlayPortal(
      controller: _dropdown,
      overlayChildBuilder: (context) => _dropdownFor(context, prefix, matches),
      child: CompositedTransformTarget(
        link: _fieldLink,
        child: _fieldBox(prefix),
      ),
    );
  }

  Widget _fieldBox(String prefix) {
    return Container(
      key: _fieldKey,
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
              inputFormatters: [
                LengthLimitingTextInputFormatter(kMaxTagNameLength),
              ],
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
              'با نوشتن عنوان، تگ‌های مرتبط پیشنهاد می‌شوند.',
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

/// A note under the task's title, from the first letter typed, on how the
/// title picks the tags that the statistics are built from. When the title
/// is too vague for that it says what a fuller one does, with an example.
/// Blue and informative: nothing is wrong, and the task saves as it is.
class TagTitleHint extends StatelessWidget {
  const TagTitleHint({
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
        final example = selection.fullerTitleExample;
        final grade = selection.bareGrade;
        // Set when the title could say more; the general note otherwise.
        final String? clarify;
        if (example != null) {
          clarify = 'هرچه عنوان کامل‌تر باشد، آمار دقیق‌تر است؛ '
              'مثلاً «$example».';
        } else if (grade != null) {
          clarify = 'با نوشتن نام درس، مثلاً «فیزیک $grade»، '
              'تگ آن خودکار انتخاب می‌شود و در آمار می‌آید.';
        } else if (selection.needsClearerTitle) {
          clarify = 'با نوشتن نام کامل درس، تگ آن خودکار انتخاب می‌شود '
              'و آمار دقیق‌تر می‌شود.';
        } else {
          clarify = null;
        }
        final text = clarify ??
            'تگ‌ها از روی عنوان انتخاب می‌شوند و آمار درس‌ها را می‌سازند.';
        return AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: !selection.hasTitle
              ? const SizedBox.shrink()
              : Directionality(
                  key: ValueKey('$keyPrefix-tags-info'),
                  textDirection: TextDirection.rtl,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.toastInfo.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: AppColors.toastInfo,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            layoutBuilder: (current, previous) => Stack(
                              alignment: AlignmentDirectional.topStart,
                              children: [
                                ...previous,
                                if (current != null) current,
                              ],
                            ),
                            child: ReText(
                              text,
                              key: clarify != null
                                  ? ValueKey('$keyPrefix-tags-clarify')
                                  : ValueKey('$keyPrefix-tags-about'),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black1,
                              textAlign: TextAlign.start,
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
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
/// server is asked, then how many of the tags are picked.
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
        } else if (selection.selected.isNotEmpty) {
          // What will be saved; the suggestions on offer are not a count to
          // work through.
          note = Row(
            key: ValueKey('$keyPrefix-tags-count'),
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            children: [
              ReText(
                convertToPersianNumbers('${selection.selected.length}'),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.black1,
              ),
              const ReText(
                ' انتخاب شده',
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

/// Known tags offered while typing, as a raised card of rows, each with a
/// plus; it scrolls past [maxHeight].
class _MatchList extends StatelessWidget {
  const _MatchList({
    required this.prefix,
    required this.matches,
    required this.onTap,
  });

  static const double rowHeight = 42;
  static const double maxHeight = 260;

  final String prefix;
  final List<String> matches;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: AppColors.whiteSec,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black1.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 6),
        children: [
          for (final text in matches)
            Semantics(
              button: true,
              label: 'افزودن تگ $text',
              excludeSemantics: true,
              child: GestureDetector(
                key: ValueKey('$prefix-tag-match-$text'),
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(text);
                },
                child: SizedBox(
                  height: rowHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.add_rounded,
                            size: 16, color: AppColors.gray),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ReText(
                            text,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black1,
                            maxLines: 1,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A tag with a check circle, like a check box: a raised white pill with a
/// filled circle once picked, a flat gray one with an empty circle and gray
/// name while off. The check pops in and the pill settles with a small
/// bounce.
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
            padding: const EdgeInsetsDirectional.only(start: 8, end: 13),
            decoration: BoxDecoration(
              color: selected ? AppColors.whiteSec : AppColors.gray1,
              borderRadius: BorderRadius.circular(100),
              // The same edge both ways, so the pill keeps its size.
              border: Border.all(
                color: selected ? AppColors.gray2 : AppColors.gray1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.black1.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : const [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CheckCircle(checked: selected),
                const SizedBox(width: 6),
                ReText(
                  text,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? AppColors.black1 : AppColors.gray,
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

/// A tag chip's mark: a dark disc with a white check that pops in, or an
/// empty ring.
class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked ? AppColors.black1 : AppColors.whiteSec,
        border: Border.all(
          color: checked ? AppColors.black1 : AppColors.dark5Color,
          width: 1.5,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: checked
            ? const Icon(
                Icons.check_rounded,
                key: ValueKey('check'),
                size: 12,
                color: AppColors.whiteSec,
              )
            : const SizedBox.shrink(key: ValueKey('empty')),
      ),
    );
  }
}
