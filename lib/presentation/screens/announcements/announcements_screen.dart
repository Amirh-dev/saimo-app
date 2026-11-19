import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/announcements/announcements_repository.dart';
import 'package:simo_learn/features/announcements/announcements_store.dart';
import 'package:simo_learn/presentation/screens/app_tabs_shell.dart';
import 'package:simo_learn/presentation/screens/consultants/list_screen.dart';
import 'package:simo_learn/presentation/screens/profile/feedback_screen.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:simo_learn/utils/jalali_text.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens what a message's button points at and counts the tap.
Future<void> openAnnouncementButton(BuildContext context, Announcement item) async {
  HapticFeedback.selectionClick();
  AnnouncementsStore.instance.reportClicked(item.id);
  final link = item.buttonUrl;
  if (link != null) {
    final uri = Uri.tryParse(link);
    if (uri != null && uri.scheme == 'https') {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return;
  }
  final tab = switch (item.buttonPage) {
    AnnouncementPage.home => AppTabsShell.home,
    AnnouncementPage.tasks => AppTabsShell.tasks,
    AnnouncementPage.goals => 2,
    AnnouncementPage.statistics => 3,
    AnnouncementPage.profile => AppTabsShell.profile,
    _ => null,
  };
  if (tab != null) {
    // Closes the inbox and anything above the tabs.
    if (!AppTabsShell.select(context, tab)) Navigator.of(context).maybePop();
    return;
  }
  switch (item.buttonPage) {
    case AnnouncementPage.counselors:
      await context.to<void>(const ConsultantListScreen());
    case AnnouncementPage.feedback:
      await context.to<void>(const FeedbackScreen());
    default:
      AppTabsShell.select(context, AppTabsShell.home);
  }
}

/// The bell in every tab's header, with the unread count.
class AnnouncementBell extends StatelessWidget {
  const AnnouncementBell({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AnnouncementsStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final unread = store.unreadCount;
        return Semantics(
          button: true,
          label: unread > 0 ? 'پیام‌ها، ${faDigits(unread)} پیام نخونده' : 'پیام‌ها',
          child: GestureDetector(
            key: const ValueKey('announcement-bell'),
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              context.to<void>(const AnnouncementsScreen());
            },
            child: SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(color: AppColors.gray1, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: SvgPicture.asset('assets/icons/bell.svg', width: 21, height: 21),
                  ),
                  if (unread > 0)
                    Positioned(
                      top: 2,
                      left: 3,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 18),
                        height: 18,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                        child: ReText(
                          unread > 9 ? '+۹' : faDigits(unread),
                          fontSize: 10,
                          fontWeight: 1000,
                          color: AppColors.whiteSec,
                          textAlign: TextAlign.center,
                          lineHeight: 1.1,
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

/// The message row in the home header (style chosen by the team): a small
/// image or a megaphone, the title, one line of text and «ببین». It stays
/// until the inbox is opened, which tapping it does.
class HomeAnnouncementRow extends StatelessWidget {
  const HomeAnnouncementRow({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AnnouncementsStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final card = store.homeCard;
        return AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: card == null ? const SizedBox(width: double.infinity) : _row(context, card),
        );
      },
    );
  }

  Widget _row(BuildContext context, Announcement card) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: GestureDetector(
          key: const ValueKey('home-announcement'),
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            AnnouncementsStore.instance.reportOpened(card.id, AnnouncementVia.home);
            context.to<void>(const AnnouncementsScreen());
          },
          child: Container(
            padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 12, 10),
            decoration: BoxDecoration(
              color: AppColors.gray1,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                if (card.imageThumbUrl != null)
                  _Thumb(url: card.imageThumbUrl!, width: 62, height: 44, radius: 12)
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.black1,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.campaign_rounded, color: AppColors.whiteSec, size: 22),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ReText(card.title, fontSize: 13.5, fontWeight: 1000, textAlign: TextAlign.right, maxLines: 1),
                      const SizedBox(height: 3),
                      ReText(card.body, fontSize: 12, color: AppColors.gray, textAlign: TextAlign.right, maxLines: 1),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.whiteSec,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: AppColors.black1.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: const ReText('ببین', fontSize: 12.5, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// «پیام‌ها»: every message the team sent this user, newest first. Opening
/// it marks them all seen, which also clears the home row and the badge.
class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key, this.repository});

  /// For tests; defaults to one built from the app's GraphQLRepository.
  final AnnouncementsRepository? repository;

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  late final AnnouncementsRepository _repo = widget.repository ??
      AnnouncementsStore.instance.repository ??
      AnnouncementsRepository(context.read<GraphQLRepository>());

  static const _page = 30;
  List<Announcement> _items = const [];
  int _total = 0;
  bool _loading = true;
  bool _loadingMore = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final inbox = await _repo.inbox(limit: _page);
      if (!mounted) return;
      setState(() {
        _items = inbox.items;
        _total = inbox.total;
      });
      // Seen from here on; the dots stay for this visit so the new ones
      // still stand out.
      if (inbox.unreadCount > 0) AnnouncementsStore.instance.markAllSeen();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _more() async {
    if (_loadingMore || _items.length >= _total) return;
    setState(() => _loadingMore = true);
    try {
      final inbox = await _repo.inbox(limit: _page, offset: _items.length);
      if (mounted) setState(() => _items = [..._items, ...inbox.items]);
    } catch (_) {
      // The next scroll tries again.
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray1,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: _body(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5));
    }
    if (_failed) {
      return _Empty(
        icon: SolarIconsOutline.inbox,
        text: 'پیام‌ها نیومد. دوباره امتحان کن.',
        action: ('دوباره', _load),
      );
    }
    if (_items.isEmpty) {
      return const _Empty(icon: SolarIconsOutline.inbox, text: 'هنوز پیامی نداری.');
    }
    final rows = <Widget>[];
    String? lastDay;
    for (final item in _items) {
      final day = _dayLabel(item.sentAt);
      if (day != lastDay) {
        rows.add(Padding(
          padding: EdgeInsets.fromLTRB(6, rows.isEmpty ? 0 : 10, 6, 8),
          child: ReText(day, fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.gray, textAlign: TextAlign.right),
        ));
        lastDay = day;
      }
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _MessageCard(item: item, onButton: () => openAnnouncementButton(context, item)),
      ));
    }
    if (_items.length < _total) {
      rows.add(Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Center(
          child: _loadingMore
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gray))
              : TextButton(onPressed: _more, child: const ReText('پیام‌های قبلی', fontSize: 13, fontWeight: FontWeight.w800)),
        ),
      ));
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        physics: const AlwaysScrollableScrollPhysics(),
        children: rows,
      ),
    );
  }

  static String _dayLabel(DateTime at) {
    final local = at.toLocal();
    final today = DateTime.now();
    final days = DateTime(today.year, today.month, today.day)
        .difference(DateTime(local.year, local.month, local.day))
        .inDays;
    if (days <= 0) return 'امروز';
    if (days == 1) return 'دیروز';
    if (days < 7) return 'این هفته';
    return JalaliText.dayMonth(Jalali.fromDateTime(local));
  }

  Widget _header(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(48),
          bottomRight: Radius.circular(48),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Spacer(),
            const ReText('پیام‌ها', color: AppColors.black1, fontSize: 16, fontWeight: 1000),
            IconButton(
              tooltip: 'بازگشت',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(SolarIconsOutline.altArrowRight, size: 22, color: AppColors.black1),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.item, required this.onButton});

  final Announcement item;
  final VoidCallback onButton;

  @override
  Widget build(BuildContext context) {
    final local = item.sentAt.toLocal();
    final time = '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    final image = item.imageUrl;
    return Container(
      padding: image == null ? const EdgeInsets.fromLTRB(18, 16, 18, 16) : const EdgeInsets.fromLTRB(8, 8, 8, 16),
      decoration: BoxDecoration(
        color: item.seen ? const Color(0xFFFBFBFD) : AppColors.whiteSec,
        borderRadius: BorderRadius.circular(26),
        boxShadow: item.seen
            ? null
            : [BoxShadow(color: AppColors.black1.withValues(alpha: 0.04), blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (image != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(aspectRatio: 2, child: _Thumb(url: image, radius: 0)),
            ),
            const SizedBox(height: 12),
          ],
          Padding(
            padding: EdgeInsets.symmetric(horizontal: image == null ? 0 : 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    if (!item.seen) ...[
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: ReText(
                        item.title,
                        fontSize: 14.5,
                        fontWeight: 1000,
                        textAlign: TextAlign.right,
                        color: item.seen ? const Color(0xFF4A4C58) : AppColors.black1,
                        overflow: TextOverflow.visible,
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ReText(time, fontSize: 11.5, color: AppColors.gray, fontWeight: FontWeight.w700),
                  ],
                ),
                const SizedBox(height: 6),
                ReText(
                  item.body,
                  fontSize: 13,
                  color: const Color(0xFF4A4C58),
                  textAlign: TextAlign.right,
                  lineHeight: 1.8,
                  overflow: TextOverflow.visible,
                  maxLines: null,
                ),
                if (item.hasButton) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: GestureDetector(
                      key: ValueKey('announcement-button-${item.id}'),
                      onTap: onButton,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 7, 15, 9),
                        decoration: BoxDecoration(
                          color: AppColors.gray1,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ReText(item.buttonLabel!, fontSize: 12.5, fontWeight: FontWeight.w900),
                            const SizedBox(width: 4),
                            const Icon(SolarIconsOutline.altArrowLeft, size: 14, color: AppColors.black1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url, this.width, this.height, required this.radius});

  final String url;
  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image(
        image: announcementImage(url),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(width: width, height: height, color: AppColors.gray2),
        frameBuilder: (_, child, frame, sync) => sync || frame != null
            ? child
            : Container(width: width, height: height, color: AppColors.gray2),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final (String, Future<void> Function())? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(color: AppColors.whiteSec, shape: BoxShape.circle),
            child: Icon(icon, size: 28, color: AppColors.gray),
          ),
          const SizedBox(height: 14),
          ReText(text, fontSize: 13.5, color: AppColors.gray, fontWeight: FontWeight.w700),
          if (action != null) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: action!.$2,
              child: ReText(action!.$1, fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}

/// Where message pictures come from; tests swap in local bytes.
@visibleForTesting
ImageProvider Function(String url) announcementImage = NetworkImage.new;

/// Persian digits for counts.
String faDigits(int n) =>
    n.toString().replaceAllMapped(RegExp(r'\d'), (m) => '۰۱۲۳۴۵۶۷۸۹'[int.parse(m[0]!)]);
