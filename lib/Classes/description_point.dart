class DescriptionPoint {
  late final String description;
  final double x;
  final double y;

  DescriptionPoint({
    required this.description,
    required this.x,
    required this.y,
  });
  @override
  String toString() {
    return '{"description": $description, "x": $x, "y": $y}';
  }
}
