import 'package:onroute_app/Classes/route_layer_data.dart';

class AvailableRoutes {
  final String routeID;
  final bool locally;
  final RouteLayerData routeLayer;

  AvailableRoutes({
    required this.routeID,
    required this.locally,
    required this.routeLayer,
  });
}

class RouteData {
  final String title;
  final String description;

  RouteData({required this.title, required this.description});
}
