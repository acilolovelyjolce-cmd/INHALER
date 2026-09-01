import 'package:flutter/material.dart';

enum CatPose {
  happy,
  cheer,
  heart,
  sit,
  sleepy,
  owner,
  yell,
  bounce,
  blueberry,
  strawberry,
  snack,
  nerd,
  flower,
  party,
  money,
  cloud,
}

class FluffyCat extends StatelessWidget {
  const FluffyCat({
    super.key,
    this.pose = CatPose.happy,
    this.size = 72,
  });

  final CatPose pose;
  final double size;

  static const _assets = {
    CatPose.happy: 'assets/doodles/cats/cat_04.png',
    CatPose.cheer: 'assets/doodles/cats/cat_03.png',
    CatPose.heart: 'assets/doodles/cats/cat_06.png',
    CatPose.sit: 'assets/doodles/cats/cat_02.png',
    CatPose.sleepy: 'assets/doodles/cats/cat_20.png',
    CatPose.owner: 'assets/doodles/cats/cat_27.png',
    CatPose.yell: 'assets/doodles/cats/cat_07.png',
    CatPose.bounce: 'assets/doodles/cats/cat_05.png',
    CatPose.blueberry: 'assets/doodles/cats/cat_01.png',
    CatPose.strawberry: 'assets/doodles/cats/cat_21.png',
    CatPose.snack: 'assets/doodles/cats/cat_00.png',
    CatPose.nerd: 'assets/doodles/cats/cat_09.png',
    CatPose.flower: 'assets/doodles/cats/cat_16.png',
    CatPose.party: 'assets/doodles/cats/cat_19.png',
    CatPose.money: 'assets/doodles/cats/cat_25.png',
    CatPose.cloud: 'assets/doodles/cats/cat_14.png',
  };

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assets[pose]!,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
    );
  }
}

/// Header / loading mascot — now the sticker cat.
class DinoMascot extends StatelessWidget {
  const DinoMascot({super.key, this.size = 72, this.pose = CatPose.happy});

  final double size;
  final CatPose pose;

  @override
  Widget build(BuildContext context) => FluffyCat(pose: pose, size: size);
}

class DoodleSparkle extends StatelessWidget {
  const DoodleSparkle({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) => FluffyCat(pose: CatPose.blueberry, size: size);
}

class DoodleHeart extends StatelessWidget {
  const DoodleHeart({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) => FluffyCat(pose: CatPose.heart, size: size);
}

class DoodleCloud extends StatelessWidget {
  const DoodleCloud({super.key, this.width = 64});

  final double width;

  @override
  Widget build(BuildContext context) => FluffyCat(pose: CatPose.cloud, size: width);
}
