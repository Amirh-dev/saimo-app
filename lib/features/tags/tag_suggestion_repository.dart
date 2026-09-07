import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/graphql/queries/__generated__/suggest_tag.req.gql.dart';

class TagSuggestionRepository {
  TagSuggestionRepository(this._graphqlRepository);

  final GraphQLRepository _graphqlRepository;

  Future<List<String>> suggestTags(String title) async {
    final normalizedTitle = title.trim();

    if (normalizedTitle.isEmpty) {
      return const <String>[];
    }

    final response = await _graphqlRepository.requestOnce(
      GSuggestTagsReq(
            (request) {
          request.vars.title = normalizedTitle;
        },
      ),
    );

    if (response.hasErrors || response.data == null) {
      throw Exception('Failed to suggest tags');
    }

    return response.data!.suggestTags.toList();
  }
}