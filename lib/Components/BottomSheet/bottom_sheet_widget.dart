import 'package:flutter/material.dart';
import 'package:onroute_app/Components/BottomSheet/Routes-List/routes_list_view.dart';

class BottomSheetWidget extends StatelessWidget {
  final Function startRoute;

  const BottomSheetWidget({super.key, required this.startRoute});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Persistent bottom sheet
        DraggableScrollableSheet(
          initialChildSize: 0.4,
          snap: true,
          snapSizes: [0.2, 0.4, 0.6, 0.9],
          minChildSize: 0.2,
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: const BoxDecoration(
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
              child: Navigator(
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    builder:
                        (_) => RoutesListView(
                          scrollController: scrollController,
                          startRoute: startRoute,
                        ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
