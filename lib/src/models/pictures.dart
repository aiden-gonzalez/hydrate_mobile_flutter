class Picture {
  final String id; // Unique ID of picture
  final String fobId; // Fountain or bathroom ID picture is for
  final String url; // Url for picture
  final String userId; // ID of user that created the picture
  final int? createdAt; // Created timestamp. Unix epoch milliseconds
  final int? updatedAt; // Updated timestamp. Unix epoch milliseconds

  Picture({
    required this.id,
    required this.fobId,
    required this.url,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  // Add a factory constructor to parse from JSON
  factory Picture.fromJson(Map<String, dynamic> json) {
    return Picture(
      id: json['id'] as String,
      fobId: json['fob_id'] as String,
      url: json['url'] as String,
      userId: json['user_id'] as String,
      createdAt: json['created_at'] as int?,
      updatedAt: json['updated_at'] as int?,
    );
  }

  // Add a method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fob_id': fobId,
      'url': url,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
