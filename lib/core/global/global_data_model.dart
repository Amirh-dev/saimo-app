/// Every tag a user can pick, with the other names of the main tags and the
/// tags under each, by the main tag's name.
typedef TagCatalog = ({
  List<String> names,
  Map<String, List<String>> aliases,
  Map<String, List<String>> children,
});

class ParentTagModel {
  final String id;
  final String name;
  final String kind;
  final String moderationStatus;

  /// Other names merged into this tag ("ریاضیات" for "ریاضی"); a title
  /// naming one names the tag.
  final List<String> aliases;

  /// Names of the approved tags under this one ("ریاضی دهم" under "ریاضی").
  final List<String> children;

  ParentTagModel({
    required this.id,
    required this.name,
    required this.kind,
    required this.moderationStatus,
    this.aliases = const [],
    this.children = const [],
  });
}
