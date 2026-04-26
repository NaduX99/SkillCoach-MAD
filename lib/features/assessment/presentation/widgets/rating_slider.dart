import 'package:flutter/material.dart';


class RatingSlider extends StatelessWidget {
  final int currentRating;
  final ValueChanged<int> onChanged;

  const RatingSlider({
    super.key,
    required this.currentRating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: const Color(0xFF1E3A8A), // Dark blue
        inactiveTrackColor: const Color(0xFFF1F5F9), // Light grey
        trackHeight: 12.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
        thumbColor: Colors.white,
        overlayColor: const Color(0xFF1E3A8A).withValues(alpha: 0.2),
        activeTickMarkColor: Colors.transparent,
        inactiveTickMarkColor: Colors.transparent,
      ),
      child: Container(
        // Adding a slight shadow to the container helps give the thumb that floating/bordered look
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
             BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ]
        ),
        child: Slider(
          value: currentRating.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          onChanged: (value) => onChanged(value.toInt()),
        ),
      ),
    );
  }
}
