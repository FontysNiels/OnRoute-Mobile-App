class AvailableRoutes {
  final String routeID;
  final RouteData routeData;
  final bool locally;

  AvailableRoutes({
    required this.routeID,
    required this.routeData,
    required this.locally,
  });
}

class RouteData {
  final String title;
  final String description;

  RouteData({required this.title, required this.description});
}
