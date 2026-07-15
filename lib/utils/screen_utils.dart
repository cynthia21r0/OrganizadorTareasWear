import 'package:flutter/widgets.dart';

bool isLikelyRoundWatch(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final ratio = size.width / size.height;
  return ratio > 0.85 && ratio < 1.15;
}

double safeHorizontalPadding(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return isLikelyRoundWatch(context) ? size.width * 0.16 : size.width * 0.07;
}

double safeVerticalPadding(BuildContext context) {
  return isLikelyRoundWatch(context) ? 10 : 6;
}
