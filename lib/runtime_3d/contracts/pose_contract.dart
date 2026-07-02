/// Pose presets — mirrors Unity PoseModule and legacy ModelPoseMode.
enum ModelPoseMode {
  standing,
  sitting,
  walking,
  running,
  jumping,
  crouching,
  kneeling,
  lying,
  armsUp,
  waving,
}

extension ModelPoseModeLabel on ModelPoseMode {
  String get label {
    switch (this) {
      case ModelPoseMode.standing:
        return '站立';
      case ModelPoseMode.sitting:
        return '坐姿';
      case ModelPoseMode.walking:
        return '走路';
      case ModelPoseMode.running:
        return '跑步';
      case ModelPoseMode.jumping:
        return '跳跃';
      case ModelPoseMode.crouching:
        return '蹲下';
      case ModelPoseMode.kneeling:
        return '跪姿';
      case ModelPoseMode.lying:
        return '躺卧';
      case ModelPoseMode.armsUp:
        return '举手';
      case ModelPoseMode.waving:
        return '挥手';
    }
  }

  String get wireName => name;
}
