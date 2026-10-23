// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'parent_tags.data.gql.g.dart';

abstract class GParentTagsData
    implements Built<GParentTagsData, GParentTagsDataBuilder> {
  GParentTagsData._();

  factory GParentTagsData([void Function(GParentTagsDataBuilder b) updates]) =
      _$GParentTagsData;

  static void _initializeBuilder(GParentTagsDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  BuiltList<GParentTagsData_parentTags> get parentTags;
  static Serializer<GParentTagsData> get serializer =>
      _$gParentTagsDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GParentTagsData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GParentTagsData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GParentTagsData.serializer,
        json,
      );
}

abstract class GParentTagsData_parentTags
    implements
        Built<GParentTagsData_parentTags, GParentTagsData_parentTagsBuilder> {
  GParentTagsData_parentTags._();

  factory GParentTagsData_parentTags(
          [void Function(GParentTagsData_parentTagsBuilder b) updates]) =
      _$GParentTagsData_parentTags;

  static void _initializeBuilder(GParentTagsData_parentTagsBuilder b) =>
      b..G__typename = 'Tag';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get name;
  _i2.GTagKind get kind;
  _i2.GTagModerationStatus get moderationStatus;
  BuiltList<GParentTagsData_parentTags_aliases>? get aliases;
  BuiltList<GParentTagsData_parentTags_children>? get children;
  static Serializer<GParentTagsData_parentTags> get serializer =>
      _$gParentTagsDataParentTagsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GParentTagsData_parentTags.serializer,
        this,
      ) as Map<String, dynamic>);

  static GParentTagsData_parentTags? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GParentTagsData_parentTags.serializer,
        json,
      );
}

abstract class GParentTagsData_parentTags_aliases
    implements
        Built<GParentTagsData_parentTags_aliases,
            GParentTagsData_parentTags_aliasesBuilder> {
  GParentTagsData_parentTags_aliases._();

  factory GParentTagsData_parentTags_aliases(
      [void Function(GParentTagsData_parentTags_aliasesBuilder b)
          updates]) = _$GParentTagsData_parentTags_aliases;

  static void _initializeBuilder(GParentTagsData_parentTags_aliasesBuilder b) =>
      b..G__typename = 'Tag';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get name;
  static Serializer<GParentTagsData_parentTags_aliases> get serializer =>
      _$gParentTagsDataParentTagsAliasesSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GParentTagsData_parentTags_aliases.serializer,
        this,
      ) as Map<String, dynamic>);

  static GParentTagsData_parentTags_aliases? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GParentTagsData_parentTags_aliases.serializer,
        json,
      );
}

abstract class GParentTagsData_parentTags_children
    implements
        Built<GParentTagsData_parentTags_children,
            GParentTagsData_parentTags_childrenBuilder> {
  GParentTagsData_parentTags_children._();

  factory GParentTagsData_parentTags_children(
      [void Function(GParentTagsData_parentTags_childrenBuilder b)
          updates]) = _$GParentTagsData_parentTags_children;

  static void _initializeBuilder(
          GParentTagsData_parentTags_childrenBuilder b) =>
      b..G__typename = 'Tag';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get name;
  _i2.GTagModerationStatus get moderationStatus;
  static Serializer<GParentTagsData_parentTags_children> get serializer =>
      _$gParentTagsDataParentTagsChildrenSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GParentTagsData_parentTags_children.serializer,
        this,
      ) as Map<String, dynamic>);

  static GParentTagsData_parentTags_children? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GParentTagsData_parentTags_children.serializer,
        json,
      );
}
