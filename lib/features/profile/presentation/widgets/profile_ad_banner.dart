import 'dart:math' as math;

import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';

class ProfileAdBanner extends StatelessWidget {
  const ProfileAdBanner({
    super.key,
    required this.imageAsset,
    required this.headline,
  });

  static const double standardWidth = 400;
  static const double standardHeight = 200;
  static const double cornerRadius = 20;

  final String imageAsset;
  final String headline;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : standardWidth;
          final width = math.min(standardWidth, availableWidth);
          final height = width * (standardHeight / standardWidth);

          return SizedBox(
            width: width,
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(cornerRadius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                    semanticLabel: context.translateInterface(
                      'بنر إعلاني بمقاس 400 في 200',
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xB31A102A)],
                      ),
                    ),
                  ),
                  const PositionedDirectional(
                    top: 12,
                    start: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xEFFFFFFF),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Text(
                          'إعلان',
                          style: TextStyle(
                            color: Color(0xFF3C2473),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: 16,
                    end: 16,
                    bottom: 14,
                    child: Text(
                      headline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
