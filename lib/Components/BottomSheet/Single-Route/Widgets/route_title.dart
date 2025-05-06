import 'package:flutter/material.dart';
import 'package:onroute_app/Components/BottomSheet/bottom_sheet_widget.dart';

class RouteTitle extends StatelessWidget {
  final String title;
  final Function setSheetWidget;
  const RouteTitle({
    super.key,
    required this.title,
    required this.setSheetWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 6,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              style: Theme.of(context).textTheme.headlineSmall,
              // Limiet op mijn telefoon is 60 (57 met deze text) +-, depending on woordlengte
              title,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 6),
          child: IconButton.filled(
            icon: Icon(Icons.close),
            onPressed: () async {
              await moveSheetTo(0.5);
              setSheetWidget(null, false);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                Theme.of(context).primaryColor.withValues(alpha: 1.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
