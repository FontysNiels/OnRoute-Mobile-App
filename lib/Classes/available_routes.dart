class AvailableRoutes {
  final String routeID;
  final String title;
  final String description;
  final bool locally;
  // probably will change when POIs are added to the route

  AvailableRoutes({
    required this.routeID,
    required this.title,
    required this.description,
    required this.locally,
  });

  Map<String, dynamic> toJson() => {
    'routeID': routeID,
    'title': title,
    'description': description,
    'locally': locally,
  };
}
