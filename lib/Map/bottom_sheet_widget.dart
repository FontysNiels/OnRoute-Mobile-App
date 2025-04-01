import 'package:flutter/material.dart';
import 'package:onroute_app/Map/BottomSheet/routes_list_view.dart';

class BottomSheetWidget extends StatelessWidget {
  final Function setRouteGraphics;

  const BottomSheetWidget({super.key, required this.setRouteGraphics});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Persistent bottom sheet
        DraggableScrollableSheet(
          initialChildSize: 0.1,
          snap: true,
          snapSizes: [0.1, 0.4, 0.6, 0.9],
          minChildSize: 0.1,
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: RoutesListView(
                scrollController: scrollController,
                setRouteGraphics: setRouteGraphics,
              ),
            );
          },
        ),
      ],
    );
  }
}
