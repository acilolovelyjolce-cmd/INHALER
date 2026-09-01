import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DinoMascot extends StatelessWidget {
  const DinoMascot({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/doodles/dino_mascot.svg',
      width: size,
      height: size,
    );
  }
}

class DoodleSparkle extends StatelessWidget {
  const DoodleSparkle({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/doodles/doodle_sparkle.svg',
      width: size,
      height: size,
    );
  }
}

class DoodleHeart extends StatelessWidget {
  const DoodleHeart({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/doodles/doodle_heart.svg',
      width: size,
      height: size,
    );
  }
}

class DoodleCloud extends StatelessWidget {
  const DoodleCloud({super.key, this.width = 64});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/doodles/doodle_cloud.svg',
      width: width,
    );
  }
}
