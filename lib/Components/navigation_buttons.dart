import 'dart:async';

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:onroute_app/Functions/file_storage.dart';
import 'package:onroute_app/main.dart';

class NavigationButtons extends StatefulWidget {
  const NavigationButtons({super.key});

  @override
  State<NavigationButtons> createState() => _NavigationButtonsState();
}


Icon _centeredIcon = Icon(Icons.gps_fixed);
Icon _currentIcon = Icon(Icons.notifications);
late StreamSubscription<LocationDisplayAutoPanMode> subscription;

class _NavigationButtonsState extends State<NavigationButtons> {
  @override
  void initState() {
    super.initState();
    subscription = mapViewController.locationDisplay.onAutoPanModeChanged
        .listen((mode) {
          if (mounted) {
            setState(() {
              mapViewController.locationDisplay.autoPanMode ==
                      LocationDisplayAutoPanMode.off
                  ? _centeredIcon = Icon(Icons.gps_not_fixed)
                  : _centeredIcon = Icon(Icons.gps_fixed);
            });
          }
        });
  }

  @override
  void dispose() {
    subscription.cancel();
    // Clears the MMPK in case it is still loaded
    clearMMPKStorage();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(
          right: 12.0,
          top:
              directionList.isNotEmpty
                  ? 8
                  : MediaQuery.of(context).padding.top + 88,
        ),
        child: Column(
          spacing: 12,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: UniqueKey(),
              onPressed:
                  () async => {
                    directionList.isNotEmpty
                        ? (
                          mapViewController.setViewpointRotation(
                            angleDegrees: 0.0,
                          ),
                          mapViewController.locationDisplay.autoPanMode =
                              LocationDisplayAutoPanMode.compassNavigation,
                        )
                        : mapViewController.locationDisplay.autoPanMode =
                            LocationDisplayAutoPanMode.recenter,
                  },
              child: _centeredIcon,
            ),

            // TODO: chilltse is LocationDisplayAutoPanMode.compassNavigation, dus die op 1ste zetten en 2de alleen noord gericht maken
            // (verder checken met voorkeur van bijv. Thomas)
            FloatingActionButton(
              heroTag: UniqueKey(),
              onPressed:
                  () => {
                    directionList.isNotEmpty
                        ? (
                          mapViewController.setViewpointRotation(
                            angleDegrees: 0.0,
                          ),
                        )
                        : mapViewController.setViewpointRotation(
                          angleDegrees: 0.0,
                        ),
                  },
              child: Icon(Icons.compass_calibration),
            ),

            directionList.isNotEmpty
                ? FloatingActionButton(
                  heroTag: UniqueKey(),
                  onPressed:
                      () => {
                        if (mounted)
                          {
                            setState(() {
                              _currentIcon =
                                  enabledNotifiation
                                      ? Icon(Icons.notifications_off)
                                      : Icon(Icons.notifications);
                              enabledNotifiation = !enabledNotifiation;
                            }),
                          },
                      },
                  child: _currentIcon,
                )
                : Container(),
          ],
        ),
      ),
    );
  }
}

