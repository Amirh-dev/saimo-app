import 'package:ferry/ferry.dart';
import 'package:gql_http_link/gql_http_link.dart';
import 'package:simo_learn/data/auth/token_storage.dart';

import '../../graphql/__generated__/schema.schema.gql.dart'
    show possibleTypesMap;

Client createFerryClient({
  required String endpoint,
  required TokenStorage tokenStorage,
}) {
  final authLink = Link.function((request, [forward]) {
    final token = tokenStorage.currentAccessToken;
    final updatedRequest = request.updateContextEntry<HttpLinkHeaders>(
      (headers) => HttpLinkHeaders(
        headers: {
          ...?headers?.headers,
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      ),
    );

    return forward!(updatedRequest);
  });

  final httpLink = HttpLink(endpoint);

  return Client(
    link: authLink.concat(httpLink),
    // No Store is supplied, so Ferry uses MemoryStore. This normalized cache
    // can serve previously loaded chats while the app process is alive, but it
    // is cleared by a full restart. Persistence would require HiveStore; this
    // project intentionally does not add that dependency here.
    cache: Cache(
      possibleTypes: possibleTypesMap,
    ),
  );
}
