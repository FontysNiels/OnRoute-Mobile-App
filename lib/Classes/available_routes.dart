class AvailableRoutes {
  final String routeID;
  final String title;
  final String description;
  final String thumbnail;
  final bool locally;
  List<String>? tags;
  dynamic viewpoint;

  AvailableRoutes({
    required this.routeID,
    required this.title,
    required this.description,
    required this.locally,
    required this.thumbnail,
    this.tags,
    this.viewpoint,
  });

  Map<String, dynamic> toJson() => {
    'routeID': routeID,
    'title': title,
    'description': description,
    'locally': locally,
    'thumbnail': thumbnail,
    'viewpoint': viewpoint,
  };
}
