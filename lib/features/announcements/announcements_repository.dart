import 'package:simo_learn/data/graphql/graphql_repository.dart';

/// An app page a message's button can open. Values match the backend's
/// AnnouncementButtonPage; a page this build does not know opens home.
enum AnnouncementPage { home, tasks, goals, statistics, counselors, profile, feedback }

const _pageNames = {
  'HOME': AnnouncementPage.home,
  'TASKS': AnnouncementPage.tasks,
  'GOALS': AnnouncementPage.goals,
  'STATISTICS': AnnouncementPage.statistics,
  'COUNSELORS': AnnouncementPage.counselors,
  'PROFILE': AnnouncementPage.profile,
  'FEEDBACK': AnnouncementPage.feedback,
};

/// Where the user first opened a message; for its statistics.
enum AnnouncementVia { push, home }

/// A message from the Saimo team (sent from the admin panel).
class Announcement {
  const Announcement({
    required this.id,
    required this.sentAt,
    required this.title,
    required this.body,
    required this.seen,
    this.imageUrl,
    this.imageThumbUrl,
    this.buttonLabel,
    this.buttonPage,
    this.buttonUrl,
  });

  final String id;
  final DateTime sentAt;
  final String title;
  final String body;
  final bool seen;
  final String? imageUrl;
  final String? imageThumbUrl;
  final String? buttonLabel;

  /// Exactly one of [buttonPage] and [buttonUrl] is set when there is a
  /// button.
  final AnnouncementPage? buttonPage;
  final String? buttonUrl;

  bool get hasButton =>
      (buttonLabel?.trim().isNotEmpty ?? false) &&
      (buttonPage != null || buttonUrl != null);

  Announcement copyWith({bool? seen}) => Announcement(
        id: id,
        sentAt: sentAt,
        title: title,
        body: body,
        seen: seen ?? this.seen,
        imageUrl: imageUrl,
        imageThumbUrl: imageThumbUrl,
        buttonLabel: buttonLabel,
        buttonPage: buttonPage,
        buttonUrl: buttonUrl,
      );

  static String? _text(Object? value) {
    final text = (value as String?)?.trim();
    return text == null || text.isEmpty ? null : text;
  }

  factory Announcement.fromJson(Map<String, dynamic> json) {
    final page = json['buttonPage'] as String?;
    return Announcement(
      id: json['id'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      seen: json['seen'] as bool? ?? true,
      imageUrl: _text(json['imageURL']),
      imageThumbUrl: _text(json['imageThumbURL']) ?? _text(json['imageURL']),
      buttonLabel: _text(json['buttonLabel']),
      // An unknown page still gets a button; it opens home.
      buttonPage: page == null ? null : (_pageNames[page] ?? AnnouncementPage.home),
      buttonUrl: _text(json['buttonURL']),
    );
  }
}

class AnnouncementInbox {
  const AnnouncementInbox({
    required this.items,
    required this.total,
    required this.unreadCount,
    this.homeCard,
  });

  final List<Announcement> items;
  final int total;
  final int unreadCount;

  /// The newest unseen message meant for the home header, if any.
  final Announcement? homeCard;

  factory AnnouncementInbox.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    final card = json['homeCard'];
    return AnnouncementInbox(
      items: [
        if (items is List)
          for (final item in items)
            if (item is Map<String, dynamic>) Announcement.fromJson(item),
      ],
      total: json['total'] as int? ?? 0,
      unreadCount: json['unreadCount'] as int? ?? 0,
      homeCard: card is Map<String, dynamic> ? Announcement.fromJson(card) : null,
    );
  }
}

/// The message inbox. Uses rawRequest because lib/graphql/schema.graphql is
/// stale; an older backend without these operations makes the calls fail and
/// the app shows no messages.
class AnnouncementsRepository {
  AnnouncementsRepository(this._graphql);

  final GraphQLRepository _graphql;

  static const _fields =
      'id sentAt title body imageURL imageThumbURL buttonLabel buttonPage buttonURL seen';

  /// The inbox, newest first. [limit] 0 fetches only the counts and the home
  /// card.
  Future<AnnouncementInbox> inbox({int limit = 30, int offset = 0}) async {
    final data = await _graphql.rawRequest(
      query: '''
query MyAnnouncements(\$limit: Int, \$offset: Int) {
  myAnnouncements(limit: \$limit, offset: \$offset) {
    total unreadCount
    homeCard { $_fields }
    items { $_fields }
  }
}
''',
      variables: {'limit': limit, 'offset': offset},
    );
    return AnnouncementInbox.fromJson(
      data['myAnnouncements'] as Map<String, dynamic>? ?? const {},
    );
  }

  /// Opening the inbox: every unseen message counts as seen.
  Future<void> markAllSeen() async {
    await _graphql.rawRequest(query: '''
mutation MarkAnnouncementsSeen {
  markAnnouncementsSeen
}
''');
  }

  Future<void> reportOpened(String id, AnnouncementVia via) =>
      _report(id, 'OPENED', via == AnnouncementVia.push ? 'PUSH' : 'HOME');

  Future<void> reportClicked(String id) => _report(id, 'CLICKED', null);

  Future<void> _report(String id, String event, String? via) async {
    await _graphql.rawRequest(
      query: r'''
mutation ReportAnnouncementEvent($id: ID!, $event: AnnouncementEvent!, $via: AnnouncementSeenVia) {
  reportAnnouncementEvent(id: $id, event: $event, via: $via)
}
''',
      variables: {'id': id, 'event': event, 'via': via},
    );
  }
}
