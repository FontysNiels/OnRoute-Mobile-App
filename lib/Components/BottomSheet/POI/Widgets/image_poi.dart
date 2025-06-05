import 'dart:io';
import 'package:flutter/material.dart';
import 'package:onroute_app/Classes/poi.dart';

class ImagePOI extends StatelessWidget {
  final Poi poiList;
  const ImagePOI({super.key, required this.poiList});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 197, 197, 197),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child:
                    poiList.asset != ''
                        ? Image.file(
                          File(poiList.asset!),
                          height: MediaQuery.of(context).size.height * 0.2,
                        )
                        : Image.asset(
                          'assets/temp.png',
                          height: MediaQuery.of(context).size.height * 0.2,
                        ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
