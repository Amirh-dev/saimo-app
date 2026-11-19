import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/graphql/graphql_endpoints.dart';

import 'push_destination.dart';

/// Whether a push's data is a message from the team.
bool isAnnouncementPush(Map<String, dynamic> data) =>
    data['kind']?.toString() == kPushKindAnnouncement &&
    (data['announcementID']?.toString().isNotEmpty ?? false);

/// Tells the server a message's push arrived, for its statistics. Runs in
/// the background isolate too, so it reads the saved access token itself
/// instead of going through the app's GraphQL client. Best effort: an
/// expired token or no network just leaves it uncounted.
Future<void> reportAnnouncementReceived(
  Map<String, dynamic> data, {
  http.Client? client,
  Future<SharedPreferences> Function()? prefs,
}) async {
  if (!isAnnouncementPush(data)) return;
  try {
    final store = await (prefs ?? SharedPreferences.getInstance)();
    final token = store.getString('access_token');
    if (token == null || token.isEmpty) return;
    final http.Client http0 = client ?? http.Client();
    try {
      await http0
          .post(
            Uri.parse(GraphQLEndpoints.http),
            headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
            body: jsonEncode({
              'query': r'mutation AnnouncementReceived($id: ID!) { reportAnnouncementEvent(id: $id, event: RECEIVED) }',
              'variables': {'id': data['announcementID'].toString()},
            }),
          )
          .timeout(const Duration(seconds: 10));
    } finally {
      if (client == null) http0.close();
    }
  } catch (error) {
    if (kDebugMode) debugPrint('[Notifications] announcement receipt failed: $error');
  }
}

/// The picture a push asks to show, or null. Only https images, at most
/// 2 MB, within a few seconds; a failure shows the text alone.
Future<Uint8List?> downloadPushImage(Map<String, dynamic> data, {http.Client? client}) async {
  final raw = data['imageURL']?.toString();
  final uri = raw == null ? null : Uri.tryParse(raw);
  if (uri == null || !(uri.scheme == 'https' || (kDebugMode && uri.scheme == 'http'))) return null;
  final http.Client http0 = client ?? http.Client();
  try {
    final response = await http0.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200 || response.bodyBytes.isEmpty || response.bodyBytes.length > 2 * 1024 * 1024) {
      return null;
    }
    return response.bodyBytes;
  } catch (_) {
    return null;
  } finally {
    if (client == null) http0.close();
  }
}
