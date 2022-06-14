import 'package:flutter/material.dart';

class BarSlider extends StatefulWidget {
  final double value;
  final double max;
  final double min;
  final String? label;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final double cornerRadius;

  const BarSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.label,
    this.cornerRadius = 11,
  })  : assert(min <= max),
        assert(value >= min && value <= max),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BarSlider();
  }
}

class _BarSlider extends State<BarSlider> {
  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackShape: BarSliderTrackShape(
          cornerRadius: Radius.circular(widget.cornerRadius),
        ),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0.0),
        thumbColor: Colors.transparent,
        trackHeight: 40.0,
        overlayColor: Colors.transparent,
      ),
      child: Slider(
        value: widget.value,
        onChanged: widget.onChanged,
        onChangeStart: widget.onChangeStart,
        onChangeEnd: widget.onChangeEnd,
        min: widget.min,
        max: widget.max,
        label: widget.label,
      ),
    );
  }
}

class BarSliderTrackShape extends SliderTrackShape {
  /// Create a slider track that draws 2 rectangles.
  const BarSliderTrackShape({
    this.disabledThumbGapWidth = 2.0,
    this.cornerRadius = const Radius.circular(11),
  });

  /// Horizontal spacing, or gap, between the disabled thumb and the track.
  ///
  /// This is only used when the slider is disabled. There is no gap around
  /// the thumb and any part of the track when the slider is enabled. The
  /// Material spec defaults this gap width 2, which is half of the disabled
  /// thumb radius.
  final double disabledThumbGapWidth;

  /// slider track corner radius
  final Radius cornerRadius;

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = true,
    bool isDiscrete = true,
  }) {
    final double overlayWidth =
        sliderTheme.overlayShape!.getPreferredSize(isEnabled, isDiscrete).width;
    final double trackHeight = sliderTheme.trackHeight!;
    assert(overlayWidth >= 0);
    assert(trackHeight >= 0);
    assert(parentBox.size.width >= overlayWidth);
    assert(parentBox.size.height >= trackHeight);

    final double trackLeft = offset.dx + overlayWidth / 2;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - overlayWidth;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    // If the slider track height is 0, then it makes no difference whether the
    // track is painted or not, therefore the painting can be a no-op.
    if (sliderTheme.trackHeight == 0) {
      return;
    }

    // Assign the track segment paints, which are left: active, right: inactive,
    // but reversed for right to left text.
    final ColorTween activeTrackColorTween = ColorTween(
        begin: sliderTheme.disabledActiveTrackColor,
        end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(
        begin: sliderTheme.disabledInactiveTrackColor,
        end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation)!;
    Paint leftTrackPaint;
    Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }

    // Used to create a gap around the thumb iff the slider is disabled.
    // If the slider is enabled, the track can be drawn beneath the thumb
    // without a gap. But when the slider is disabled, the track is shortened
    // and this gap helps determine how much shorter it should be.
    // TODO(clocksmith): The new Material spec has a gray circle in place of this gap.
    double horizontalAdjustment = 0.0;
    if (!isEnabled) {
      final double disabledThumbRadius =
          sliderTheme.thumbShape!.getPreferredSize(false, isDiscrete).width /
              2.0;
      final double gap = disabledThumbGapWidth * (1.0 - enableAnimation.value);
      horizontalAdjustment = disabledThumbRadius + gap;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Rect leftTrackSegment = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx - horizontalAdjustment,
      trackRect.bottom,
    );

    //right side of bar / background
    context.canvas.drawRRect(
        RRect.fromRectAndRadius(trackRect, cornerRadius),
        Paint()
          ..color = rightTrackPaint.color
          ..blendMode = BlendMode.src);

    //mask
    context.canvas.drawRect(leftTrackSegment,
        Paint()..color = const Color.fromARGB(255, 255, 255, 255));

    //left side of bar
    context.canvas.drawRRect(
        RRect.fromRectAndRadius(trackRect, cornerRadius),
        Paint()
          ..color = leftTrackPaint.color
          ..blendMode = BlendMode.srcATop);

    //background of bar
    context.canvas
        .drawColor(const Color.fromARGB(255, 255, 255, 255), BlendMode.dstATop);
  }
}
