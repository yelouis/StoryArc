import 'package:flutter/material.dart';

class MoodColorMapper {
  static Color getColor(double score) {
    // Ensure score is within [-1.0, 1.0]
    score = score.clamp(-1.0, 1.0);

    if (score < 0) {
      // Interpolate Red to Yellow
      return Color.lerp(Colors.redAccent, Colors.amberAccent, score + 1.0) ?? Colors.amberAccent;
    } else {
      // Interpolate Yellow to Green
      return Color.lerp(Colors.amberAccent, Colors.greenAccent, score) ?? Colors.greenAccent;
    }
  }

  static String getMoodLabel(double score) {
    if (score <= -0.6) return "Heavy";
    if (score <= -0.2) return "Difficult";
    if (score < 0.2) return "Neutral";
    if (score < 0.6) return "Positive";
    return "Radiant";
  }
}
