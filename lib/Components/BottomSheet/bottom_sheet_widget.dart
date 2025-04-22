import 'package:flutter/material.dart';
import 'package:onroute_app/Components/BottomSheet/Routes-List/routes_list_view.dart';

class BottomSheetWidget extends StatefulWidget {
  final Function startRoute;
  const BottomSheetWidget({super.key, required this.startRoute});

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

double sheetSize = 0.4;

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  late final DraggableScrollableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DraggableScrollableController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void moveSheetTo(double size) async {
    while (!_controller.isAttached) {
      await Future.delayed(Duration(milliseconds: 50));
    }

    _controller.animateTo(
      size,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    await Future.delayed(Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Persistent bottom sheet
        DraggableScrollableSheet(
          controller: _controller,
          initialChildSize: sheetSize,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Navigator(
                  onGenerateRoute: (settings) {
                    return MaterialPageRoute(
                      builder:
                          (_) => RoutesListView(
                            scrollController: scrollController,
                            startRoute: widget.startRoute,
                            changesheetsize: moveSheetTo,
                          ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
