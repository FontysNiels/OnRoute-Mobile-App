import 'package:onroute_app/Classes/available_routes.dart';
import 'package:onroute_app/Classes/poi.dart';

class WebMapCollection {
  String webmapId;
  List<AvailableRoutes> availableRoute;
  List<Poi> pointsOfInterest;
  final bool locally;
  String title;
  String description;

  WebMapCollection({
    required this.webmapId,
    required this.pointsOfInterest,
    required this.availableRoute,
    required this.locally,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'pointsOfInterest': pointsOfInterest.map((poi) => poi.toJson()).toList(),
    'availableRoute':
        availableRoute
            .map((availableRoutes) => availableRoutes.toJson)
            .toList(),
  };
}
