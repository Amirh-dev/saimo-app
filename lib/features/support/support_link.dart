import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Used when the server has no support link set, or can't be reached.
const String kDefaultSupportLink = 'https://t.me/SaimoSupport';

/// Admins set the WhatsApp/Telegram support link on the website
/// (`adminSetSupportLink`). The query is public, so it works logged out.
Future<String> fetchSupportLink(GraphQLRepository graphql) async {
  try {
    final data = await graphql.rawRequest(
      query: r'''
query SupportLink {
  supportLink
}
''',
      requiresAuth: false,
    );
    final link = data['supportLink'];
    if (link is String && link.trim().isNotEmpty) return link.trim();
  } catch (_) {
    // Fall through to the default: support must stay reachable.
  }
  return kDefaultSupportLink;
}

/// Opens the support chat in Telegram/WhatsApp (or the browser).
Future<void> openSupport(BuildContext context) async {
  final link = await fetchSupportLink(context.read<GraphQLRepository>());
  final uri = Uri.tryParse(link);
  var opened = false;
  if (uri != null) {
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
  }
  if (!opened && context.mounted) {
    showReToast(context, 'باز کردن پشتیبانی ممکن نشد', ReToastType.error);
  }
}
