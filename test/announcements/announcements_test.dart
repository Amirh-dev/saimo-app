import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
// gql_exec is a transitive test fixture API exposed through Ferry's link stack.
// ignore: depend_on_referenced_packages
import 'package:gql_exec/gql_exec.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/data/notifications/announcement_push.dart';
import 'package:simo_learn/data/notifications/notification_service.dart';
import 'package:simo_learn/data/notifications/push_destination.dart';
import 'package:simo_learn/features/announcements/announcements_repository.dart';
import 'package:simo_learn/features/announcements/announcements_store.dart';
import 'package:simo_learn/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:simo_learn/features/dashboard/dashboard_repository.dart';
import 'package:simo_learn/features/profile/profile_repository.dart';
import 'package:simo_learn/presentation/screens/announcements/announcements_screen.dart';
import 'package:simo_learn/presentation/screens/app_tabs_shell.dart';
import 'package:simo_learn/presentation/screens/consultants/active_counselor_store.dart';
import 'package:simo_learn/presentation/screens/dashboard/index.dart';

import '../tasks/support/app_fonts.dart';

final _picture = File('test/announcements/fixtures/message.png').readAsBytesSync();

Announcement _message(
  String id, {
  required String title,
  String body = 'حالا می‌تونی یه تسک رو برای چند روز هفته تکرار کنی، دیگه لازم نیست هر هفته از اول بچینی.',
  bool image = false,
  bool seen = false,
  AnnouncementPage? page,
  String? link,
  String? label,
  Duration ago = Duration.zero,
}) =>
    Announcement(
      id: id,
      sentAt: DateTime.now().subtract(ago),
      title: title,
      body: body,
      seen: seen,
      imageUrl: image ? 'https://media.test/$id/1200.jpg' : null,
      imageThumbUrl: image ? 'https://media.test/$id/480.jpg' : null,
      buttonLabel: label,
      buttonPage: page,
      buttonUrl: link,
    );

class _Inbox implements AnnouncementsRepository {
  _Inbox(this.items);

  final List<Announcement> items;
  int markedSeen = 0;
  final opened = <(String, AnnouncementVia)>[];
  final clicked = <String>[];

  @override
  Future<AnnouncementInbox> inbox({int limit = 30, int offset = 0}) async {
    final unread = items.where((i) => !i.seen).length;
    return AnnouncementInbox(
      items: limit == 0 ? const [] : items.skip(offset).take(limit).toList(),
      total: items.length,
      unreadCount: unread,
      homeCard: items.where((i) => !i.seen).firstOrNull,
    );
  }

  @override
  Future<void> markAllSeen() async => markedSeen++;

  @override
  Future<void> reportOpened(String id, AnnouncementVia via) async => opened.add((id, via));

  @override
  Future<void> reportClicked(String id) async => clicked.add(id);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Dashboard implements DashboardRepository {
  @override
  Stream<String> get serverChanges => const Stream.empty();
  @override
  Future<DashboardCache> readCache() async => const DashboardCache();
  @override
  Future<void> clearCache() async {}
  @override
  Future<ProfileUser> getProfile() async =>
      const ProfileUser(id: 'u', username: 'ali', fullName: 'علی رضایی', simoCoins: 0, score: 0, isPremium: false);
  @override
  Future<List<DashboardGoal>> getGoals() async => const [];
  @override
  Future<List<DashboardTask>> getTasks() async => const [];
  @override
  Future<DashboardConsistency> getConsistency() async => const DashboardConsistency(
        level: 1, maxLevel: 5, countedToday: false, plannedSeconds: 6300, progressSeconds: 1500,
        studiedSeconds: 1500, minStudySeconds: 5400, targetPercentage: 85.7, remainingSeconds: 3900, fraction: 0.28,
      );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _shot(WidgetTester tester, String name) async {
  const dir = String.fromEnvironment('SHOT_DIR');
  if (dir.isEmpty) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  File('$dir/$name.png').writeAsBytesSync(bytes!);
}

/// Lets network pictures decode before a screenshot.
Future<void> _settleImages(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      final image = element.widget as Image;
      await precacheImage(image.image, element);
    }
  });
  await tester.pumpAndSettle();
}

Future<DashboardCubit> _pumpHome(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390 * 2, 844 * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  ActiveCounselorStore.instance.debugReset();
  ActiveCounselorStore.instance.set(null);
  final cubit = DashboardCubit(_Dashboard(), settle: Duration.zero);
  final graphql = GraphQLRepository(
    Client(link: Link.function((request, [forward]) => const Stream<Response>.empty())),
    tokenStorage: await TokenStorage.create(),
    logger: GraphQLConsoleLogger(endpoint: 'https://example.invalid/graphql'),
  );
  await tester.pumpWidget(
    RepositoryProvider.value(
      value: graphql,
      child: BlocProvider.value(
        value: cubit,
        child: const MaterialApp(
          home: RepaintBoundary(
            child: AppTabsShell(titles: ['خوش اومدی'], tabs: [DashboardScreen()]),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
  return cubit;
}

Future<void> _closeHome(WidgetTester tester, DashboardCubit cubit) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(minutes: 5));
  await tester.runAsync(cubit.close);
}

void main() {
  setUpAll(loadAppFonts);
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    announcementImage = (url) => MemoryImage(_picture);
  });
  tearDown(AnnouncementsStore.instance.clear);

  group('Announcement.fromJson', () {
    test('reads a message and falls back for unknown pages and thumbnails', () {
      final item = Announcement.fromJson({
        'id': 'a1',
        'sentAt': '2026-11-19T15:00:00Z',
        'title': 'سلام',
        'body': 'متن',
        'imageURL': 'https://m/1200.jpg',
        'imageThumbURL': null,
        'buttonLabel': 'ببین',
        'buttonPage': 'SOMETHING_NEW',
        'buttonURL': null,
        'seen': false,
      });
      expect(item.imageThumbUrl, 'https://m/1200.jpg');
      expect(item.buttonPage, AnnouncementPage.home);
      expect(item.hasButton, isTrue);
      expect(Announcement.fromJson({'id': 'a2', 'sentAt': '2026-11-19T15:00:00Z', 'buttonLabel': ' '}).hasButton, isFalse);
    });
  });

  group('pushes', () {
    final push = {'type': kPushTypeConsistencyAtRisk, 'kind': kPushKindAnnouncement, 'announcementID': 'a1'};

    test('a message push opens the inbox and has its own notification', () {
      expect(pushDestination(push), PushDestination.announcements);
      expect(isAnnouncementPush(push), isTrue);
      expect(isAnnouncementPush({'type': kPushTypeConsistencyAtRisk, 'kind': kReminderPlanEmpty}), isFalse);
      expect(generalNotificationKey(push), '$kPushTypeConsistencyAtRisk:$kPushKindAnnouncement:a1');
      expect(
        generalNotificationKey({...push, 'announcementID': 'a2'}),
        isNot(generalNotificationKey(push)),
      );
    });

    test('an arrived push is reported with the saved token', () async {
      SharedPreferences.setMockInitialValues({'access_token': 'tok'});
      late http.Request sent;
      final client = MockClient((request) async {
        sent = request;
        return http.Response('{"data":{"reportAnnouncementEvent":true}}', 200);
      });
      await reportAnnouncementReceived(push, client: client);
      expect(sent.headers['Authorization'], 'Bearer tok');
      final body = jsonDecode(sent.body) as Map<String, dynamic>;
      expect(body['query'], contains('event: RECEIVED'));
      expect(body['variables'], {'id': 'a1'});
    });

    test('no token, or not a message: nothing is sent', () async {
      var calls = 0;
      final client = MockClient((_) async {
        calls++;
        return http.Response('{}', 200);
      });
      SharedPreferences.setMockInitialValues({});
      await reportAnnouncementReceived(push, client: client);
      SharedPreferences.setMockInitialValues({'access_token': 'tok'});
      await reportAnnouncementReceived({'type': kPushTypeConsistencyAtRisk, 'kind': kReminderPlanEmpty}, client: client);
      expect(calls, 0);
    });

    test('a push picture loads only from https and falls back on errors', () async {
      final ok = MockClient((_) async => http.Response.bytes(_picture, 200));
      expect(await downloadPushImage({'imageURL': 'https://m/a.jpg'}, client: ok), isNotNull);
      expect(await downloadPushImage({'imageURL': 'ftp://m/a.jpg'}, client: ok), isNull);
      expect(await downloadPushImage({}, client: ok), isNull);
      final missing = MockClient((_) async => http.Response('', 404));
      expect(await downloadPushImage({'imageURL': 'https://m/a.jpg'}, client: missing), isNull);
    });
  });

  testWidgets('the home header shows the message until the inbox is opened', (tester) async {
    final inbox = _Inbox([
      _message('a1', title: 'قابلیت جدید: تکرار هفتگی', image: true, page: AnnouncementPage.tasks, label: 'ببین چطوری'),
      _message('a2',
          title: 'آزمون آزمایشی جمعه',
          body: 'برنامه‌ی این هفته‌ت رو با آزمون جمعه هماهنگ کن. فقط ۲ روز مونده.',
          link: 'https://saimo.app/blog/azmoon',
          label: 'برنامه‌م رو ببینم',
          ago: const Duration(days: 1)),
      _message('a3',
          title: 'به سایمو خوش اومدی',
          body: 'اولین قدم: برنامه‌ی امروزت رو بچین. هر سوالی داشتی، از پشتیبانی بپرس.',
          seen: true,
          ago: const Duration(days: 9)),
    ]);
    final store = AnnouncementsStore.instance..attach(inbox);
    await store.refresh(force: true);
    expect(store.unreadCount, 2);

    final cubit = await _pumpHome(tester);
    await _settleImages(tester);
    expect(find.byKey(const ValueKey('home-announcement')), findsOneWidget);
    expect(find.text('قابلیت جدید: تکرار هفتگی'), findsOneWidget);
    expect(find.text('۲'), findsOneWidget);
    await _shot(tester, 'home-message-image');

    await tester.tap(find.byKey(const ValueKey('home-announcement')));
    await tester.pumpAndSettle();
    await _settleImages(tester);
    expect(find.byType(AnnouncementsScreen), findsOneWidget);
    expect(inbox.opened, [('a1', AnnouncementVia.home)]);
    expect(inbox.markedSeen, 1);
    expect(store.unreadCount, 0);
    expect(store.homeCard, isNull);
    expect(find.text('امروز'), findsOneWidget);
    expect(find.text('دیروز'), findsOneWidget);
    await _shot(tester, 'inbox');

    await tester.tap(find.byKey(const ValueKey('announcement-button-a1')));
    await tester.pumpAndSettle();
    expect(inbox.clicked, ['a1']);

    await _closeHome(tester, cubit);
  });

  testWidgets('a message without a picture shows the megaphone', (tester) async {
    AnnouncementsStore.instance.set(
      unreadCount: 1,
      homeCard: _message('b1', title: 'آزمون آزمایشی جمعه', body: 'برنامه‌ت رو با آزمون هماهنگ کن'),
    );
    final cubit = await _pumpHome(tester);
    expect(find.byIcon(Icons.campaign_rounded), findsOneWidget);
    expect(find.text('۱'), findsOneWidget);
    await _shot(tester, 'home-message-text');
    await _closeHome(tester, cubit);
  });

  testWidgets('no message: no row and no badge', (tester) async {
    final cubit = await _pumpHome(tester);
    expect(find.byKey(const ValueKey('home-announcement')), findsNothing);
    expect(find.byKey(const ValueKey('announcement-bell')), findsOneWidget);
    await _shot(tester, 'home-no-message');
    await _closeHome(tester, cubit);
  });

  testWidgets('an empty inbox says so', (tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: RepaintBoundary(child: AnnouncementsScreen(repository: _Inbox(const [])))));
    await tester.pumpAndSettle();
    expect(find.text('هنوز پیامی نداری.'), findsOneWidget);
    await _shot(tester, 'inbox-empty');
  });
}
