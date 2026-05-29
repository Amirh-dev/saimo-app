import 'package:ferry/ferry.dart';
import 'package:gql_http_link/gql_http_link.dart';
 
import '../../graphql/__generated__/schema.schema.gql.dart'
    show possibleTypesMap;

Client createFerryClient({
  required String endpoint,
  String? token,
}) {
  final authLink = Link.function((request, [forward]) {
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
    cache: Cache(
      possibleTypes: possibleTypesMap,
    ),
  );
}