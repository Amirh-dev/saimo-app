import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:url_launcher/url_launcher.dart';

/// Used when the server has no support username set, or can't be reached.
const String kDefaultSupportTelegram = 'SaimoSupport';

/// Support usernames (no @). A null one is not offered.
class SupportContacts {
  const SupportContacts({this.telegram, this.bale});

  final String? telegram;
  final String? bale;

  static const fallback = SupportContacts(telegram: kDefaultSupportTelegram);

  bool get isEmpty => telegram == null && bale == null;
}

String? _username(Object? value) {
  if (value is! String) return null;
  final name = value.trim().replaceFirst('@', '');
  return name.isEmpty ? null : name;
}

/// The Telegram username in a stored t.me support link, from servers that
/// predate `supportContacts`.
String? telegramFromLink(String? link) {
  final uri = Uri.tryParse(link?.trim() ?? '');
  if (uri == null) return null;
  final host = uri.host.toLowerCase().replaceFirst('www.', '');
  if (host != 't.me' && host != 'telegram.me') return null;
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.length != 1) return null;
  return _username(segments.single);
}

/// Last answer, so the sheet opens filled the second time.
SupportContacts? _cached;

/// Admins set the Telegram and Bale usernames on the website
/// (`adminSetSupportContacts`). The query is public, so it works logged out.
Future<SupportContacts> fetchSupportContacts(GraphQLRepository graphql) async {
  try {
    final data = await graphql.rawRequest(
      query: r'''
query SupportContacts {
  supportContacts { telegram bale }
}
''',
      requiresAuth: false,
    );
    final raw = data['supportContacts'];
    if (raw is Map) {
      final contacts = SupportContacts(
        telegram: _username(raw['telegram']),
        bale: _username(raw['bale']),
      );
      // Support must stay reachable, even with both cleared.
      return _cached = contacts.isEmpty ? SupportContacts.fallback : contacts;
    }
  } catch (_) {
    // An older server has only supportLink; try that below.
  }
  try {
    final data = await graphql.rawRequest(
      query: r'''
query SupportLink {
  supportLink
}
''',
      requiresAuth: false,
    );
    final telegram = telegramFromLink(data['supportLink'] as String?);
    if (telegram != null) {
      return _cached = SupportContacts(telegram: telegram);
    }
  } catch (_) {
    // Fall through to the default.
  }
  return _cached ?? SupportContacts.fallback;
}

/// Opens the support sheet: Telegram and Bale, whichever are set.
Future<void> openSupport(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SupportSheet(
      load: () => fetchSupportContacts(context.read<GraphQLRepository>()),
      initial: _cached,
    ),
  );
}

enum SupportMessenger {
  telegram('تلگرام', 'assets/icons/telegram.svg', Color(0xFFE8F4FB)),
  bale('بله', 'assets/icons/bale.svg', Color(0xFFE5F7F3));

  const SupportMessenger(this.label, this.icon, this.tint);

  final String label;
  final String icon;
  final Color tint;

  Uri link(String username) => this == SupportMessenger.telegram
      ? Uri.https('t.me', '/$username')
      : Uri.https('ble.ir', '/$username');
}

class SupportSheet extends StatefulWidget {
  const SupportSheet({super.key, required this.load, this.initial});

  final Future<SupportContacts> Function() load;

  /// Shown at once while [load] refreshes it.
  final SupportContacts? initial;

  @override
  State<SupportSheet> createState() => _SupportSheetState();
}

class _SupportSheetState extends State<SupportSheet> {
  SupportContacts? _contacts;

  @override
  void initState() {
    super.initState();
    _contacts = widget.initial;
    widget.load().then((contacts) {
      if (mounted) setState(() => _contacts = contacts);
    });
  }

  Future<void> _open(SupportMessenger messenger, String username) async {
    var opened = false;
    try {
      opened = await launchUrl(
        messenger.link(username),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (!mounted) return;
    if (opened) {
      Navigator.of(context).maybePop();
    } else {
      showReToast(context, 'باز کردن ${messenger.label} ممکن نشد',
          ReToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contacts = _contacts;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.whiteSec,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCDDE3),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(
                      child: ReText(
                        'پشتیبانی سایمو',
                        color: AppColors.black1,
                        fontSize: 18,
                        fontWeight: 900,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'بستن',
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.gray1,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: AppColors.black1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const ReText(
                  'هر سوالی داری، بپرس.',
                  color: AppColors.gray,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 18),
                if (contacts == null)
                  const SizedBox(
                    height: 120,
                    child: Center(
                        child: CircularProgressIndicator.adaptive()),
                  )
                else ...[
                  if (contacts.telegram != null)
                    _MessengerTile(
                      messenger: SupportMessenger.telegram,
                      username: contacts.telegram!,
                      onTap: () => _open(
                          SupportMessenger.telegram, contacts.telegram!),
                    ),
                  if (contacts.telegram != null && contacts.bale != null)
                    const SizedBox(height: 10),
                  if (contacts.bale != null)
                    _MessengerTile(
                      messenger: SupportMessenger.bale,
                      username: contacts.bale!,
                      onTap: () =>
                          _open(SupportMessenger.bale, contacts.bale!),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessengerTile extends StatelessWidget {
  const _MessengerTile({
    required this.messenger,
    required this.username,
    required this.onTap,
  });

  final SupportMessenger messenger;
  final String username;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.gray1,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        key: ValueKey('support-${messenger.name}'),
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: messenger.tint,
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(messenger.icon, width: 26, height: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ReText(
                      messenger.label,
                      color: AppColors.black1,
                      fontSize: 15,
                      fontWeight: 900,
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 2),
                    ReText(
                      '@$username',
                      color: AppColors.gray,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.ltr,
                      // Usernames keep Latin digits.
                      isPersian: false,
                    ),
                  ],
                ),
              ),
              const Icon(
                SolarIconsOutline.altArrowLeft,
                size: 18,
                color: AppColors.gray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
