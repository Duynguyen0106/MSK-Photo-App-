/// Anatomical regions selectable during check-in.
enum BodyPart {
  head,
  neck,
  leftShoulder,
  rightShoulder,
  chest,
  upperBack,
  lowerBack,
  abdomen,
  leftElbow,
  rightElbow,
  leftWrist,
  rightWrist,
  leftHip,
  rightHip,
  leftKnee,
  rightKnee,
  leftAnkle,
  rightAnkle,
}

/// Human-readable label for a [BodyPart].
String labelFor(BodyPart part) {
  switch (part) {
    case BodyPart.head:
      return 'Head';
    case BodyPart.neck:
      return 'Neck';
    case BodyPart.leftShoulder:
      return 'Left shoulder';
    case BodyPart.rightShoulder:
      return 'Right shoulder';
    case BodyPart.chest:
      return 'Chest';
    case BodyPart.upperBack:
      return 'Upper back';
    case BodyPart.lowerBack:
      return 'Lower back';
    case BodyPart.abdomen:
      return 'Abdomen';
    case BodyPart.leftElbow:
      return 'Left elbow';
    case BodyPart.rightElbow:
      return 'Right elbow';
    case BodyPart.leftWrist:
      return 'Left wrist';
    case BodyPart.rightWrist:
      return 'Right wrist';
    case BodyPart.leftHip:
      return 'Left hip';
    case BodyPart.rightHip:
      return 'Right hip';
    case BodyPart.leftKnee:
      return 'Left knee';
    case BodyPart.rightKnee:
      return 'Right knee';
    case BodyPart.leftAnkle:
      return 'Left ankle';
    case BodyPart.rightAnkle:
      return 'Right ankle';
  }
}

/// Coarse region key for question mapping.
String regionFor(BodyPart part) {
  switch (part) {
    case BodyPart.head:
      return 'head';
    case BodyPart.neck:
      return 'neck';
    case BodyPart.leftShoulder:
    case BodyPart.rightShoulder:
      return 'shoulder';
    case BodyPart.chest:
      return 'chest';
    case BodyPart.upperBack:
    case BodyPart.lowerBack:
      return 'back';
    case BodyPart.abdomen:
      return 'abdomen';
    case BodyPart.leftElbow:
    case BodyPart.rightElbow:
      return 'elbow';
    case BodyPart.leftWrist:
    case BodyPart.rightWrist:
      return 'wrist';
    case BodyPart.leftHip:
    case BodyPart.rightHip:
      return 'hip';
    case BodyPart.leftKnee:
    case BodyPart.rightKnee:
      return 'knee';
    case BodyPart.leftAnkle:
    case BodyPart.rightAnkle:
      return 'ankle';
  }
}

/// Parse a [BodyPart] from its enum name (Hive storage).
BodyPart bodyPartFromName(String name) =>
    BodyPart.values.firstWhere((p) => p.name == name);
