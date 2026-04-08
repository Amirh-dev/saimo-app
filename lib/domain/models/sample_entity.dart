class SampleEntity {
  final int id;
  final String title;
  final DateTime? createdAt;

  SampleEntity({
    required this.id,
    required this.title,
    this.createdAt,
  });

  factory SampleEntity.fromJson(Map<String, dynamic> json) {
    return SampleEntity(
      id: json['id'] as int,
      title: json['title'] as String,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  SampleEntity copyWith({
    int? id,
    String? title,
    DateTime? createdAt,
  }) {
    return SampleEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isValid => title.isNotEmpty;
}
