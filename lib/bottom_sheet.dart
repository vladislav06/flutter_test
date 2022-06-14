import 'package:fl_test/bar_slider.dart';
import 'package:flutter/material.dart';

class BottomSheetTest extends StatefulWidget {
  const BottomSheetTest({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BottomSheetTest();
  }
}

class _BottomSheetTest extends State<BottomSheetTest> {
  double _currentSliderValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text('showBottomSheet $_currentSliderValue'),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setSheetState) {
                  return SizedBox(
                    height: 400,
                    child: BarSlider(
                      value: _currentSliderValue,
                      max: 100,
                      label: _currentSliderValue.round().toString(),
                      onChanged: (double value) {
                        setSheetState(() {
                          _currentSliderValue = value;
                        });
                        setState(() {});
                      },
                    ),
                  );
                });
              },
            );
          },
        ),
      ),
    );
  }
}
