import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Portfolio project synchronized with the Django REST Framework API.
///
/// Field names follow `ProjectSerializer` on the backend. Dates are kept as
/// `yyyy-MM-dd` strings because DRF `DateField` rejects full ISO datetimes.
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    required this.title,
    required this.role,
    required this.category,
    required this.description,
    required this.techStack,
    required this.startedAt,
    this.endedAt,
    this.highlights = '',
    this.liveUrl = '',
    this.githubUrl = '',
    this.id,
    this.categoryDisplay = '',
    this.thumbnailUrl = '',
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  /// Assigned by the server, so it is left out of POST bodies.
  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String role;

  /// Category code accepted by the API (`web`, `data`, `competition`, `course`).
  final String category;

  /// Human readable category, read-only on the server.
  @JsonKey(includeToJson: false, defaultValue: '')
  final String categoryDisplay;
  final String description;
  @JsonKey(defaultValue: '')
  final String highlights;

  /// Comma separated technologies, e.g. `Flutter, Django`.
  final String techStack;

  /// Server-relative path or absolute URL; empty when there is no image.
  @JsonKey(includeToJson: false, defaultValue: '')
  final String thumbnailUrl;
  @JsonKey(defaultValue: '')
  final String liveUrl;
  @JsonKey(defaultValue: '')
  final String githubUrl;
  final String startedAt;

  /// Null means the project is still ongoing; omitted from the body then.
  @JsonKey(includeIfNull: false)
  final String? endedAt;

  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  bool get isOngoing => endedAt == null;

  List<String> get techList => techStack
      .split(',')
      .map((tech) => tech.trim())
      .where((tech) => tech.isNotEmpty)
      .toList();

  List<String> get highlightList => highlights
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
}
