import 'package:flutter/material.dart';

/// Festive promo banner shown at the top of each Home mode.
///
/// Artwork is a text-free asset; all copy is rendered as real widgets.
class ModePromoBanner extends StatelessWidget {
  final String asset;
  final String title;
  final String subtitle;
  final Color shadowColor;
  final EdgeInsetsGeometry margin;

  const ModePromoBanner({
    super.key,
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.shadowColor,
    this.margin = const EdgeInsets.fromLTRB(16, 8, 16, 10),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 900 / 330,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(asset, fit: BoxFit.cover, gaplessPlayback: true),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 0, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.58,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              shadows: [
                                Shadow(color: Colors.black38, blurRadius: 4),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(color: Colors.black38, blurRadius: 3),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
