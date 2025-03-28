class DescriptionPoint {
  late final String description;
  final double x;
  final double y;
  final double angle;

  DescriptionPoint({
    required this.description,
    required this.x,
    required this.y,
    required this.angle,
  });
  @override
  String toString() {
    return '{"description": $description, "x": $x, "y": $y, "direct": $angle}';
  }
}
