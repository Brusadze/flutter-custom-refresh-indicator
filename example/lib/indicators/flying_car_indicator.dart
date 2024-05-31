/*
  TODO - Not working yet
*/

import 'dart:async';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';

class _Car {

  static const _assets = [
    "assets/car_indicator/sign1.png",
    "assets/car_indicator/sign2.png",
    "assets/car_indicator/sign3.png",
    "assets/car_indicator/sign4.png",
  ];

  AnimationController? controller;
  //final Color color;
  final AssetImage image;
  final double width;
  final double dy;
  final double initialValue;
  final Duration duration;

  _Car({
    // required this.color,
    required this.image,
    required this.width,
    required this.dy,
    required this.initialValue,
    required this.duration,
  });
}

class CarIndicator extends StatefulWidget {
  final Widget? child; // Making child parameter optional by using Widget?
  const CarIndicator({
    super.key,
    this.child, // Marking child as optional
  });

  @override
  State<CarIndicator> createState() => _CarIndicatorState();
}

class _CarIndicatorState extends State<CarIndicator> with TickerProviderStateMixin {
  static final _planeTween = CurveTween(curve: Curves.easeInOut);
  late AnimationController _planeController;

  @override
  void initState() {
    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _setupCloudsAnimationControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) => _precacheImages());
    super.initState();
  }

  void _precacheImages() {
    for (final config in _cars) {
      unawaited(precacheImage(config.image, context));
    }
  }

  static final _cars = [
    _Car(
      //color: Colors.transparent,
      initialValue: 0.6,
      dy: 10.0,
      image: AssetImage(_Car._assets[1]),
      width: 100,
      duration: const Duration(milliseconds: 1600),
    ),
    _Car(
      //color: Colors.transparent,
      initialValue: 0.15,
      dy: 25.0,
      image: AssetImage(_Car._assets[3]),
      width: 40,
      duration: const Duration(milliseconds: 1600),
    ),
    _Car(
      //color: Colors.transparent,
      initialValue: 0.3,
      dy: 65.0,
      image: AssetImage(_Car._assets[2]),
      width: 60,
      duration: const Duration(milliseconds: 1600),
    ),
    _Car(
      //color: Colors.transparent,
      initialValue: 0.8,
      dy: 70.0,
      image: AssetImage(_Car._assets[3]),
      width: 100,
      duration: const Duration(milliseconds: 1600),
    ),
    _Car(
      //color: Colors.transparent,
      initialValue: 0.0,
      dy: 10,
      image: AssetImage(_Car._assets[0]),
      width: 80,
      duration: const Duration(milliseconds: 1600),
    ),
  ];

  void _setupCloudsAnimationControllers() {
    for (final cloud in _cars) {
      cloud.controller = AnimationController(
        vsync: this,
        duration: cloud.duration,
        value: cloud.initialValue,
      );
    }
  }

  void _startPlaneAnimation() {
    _planeController.repeat(reverse: true);
  }

  void _stopPlaneAnimation() {
    _planeController
      ..stop()
      ..animateTo(0.0, duration: const Duration(milliseconds: 100));
  }

  void _stopCloudAnimation() {
    for (final cloud in _cars) {
      cloud.controller!.stop();
    }
  }

  void _startCloudAnimation() {
    for (final cloud in _cars) {
      cloud.controller!.repeat();
    }
  }

  void _disposeCloudsControllers() {
    for (final cloud in _cars) {
      cloud.controller!.dispose();
    }
  }

  @override
  void dispose() {
    _planeController.dispose();
    _disposeCloudsControllers();
    super.dispose();
  }

  static const _offsetToArmed = 150.0;

  @override
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final screenWidth = constraints.maxWidth;
      final plane = AnimatedBuilder(
        animation: _planeController,
        child: Image.asset(
          "assets/car_indicator/cybercar.png",
          width: 350,
          height: 50,
          fit: BoxFit.contain,
        ),
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(
            offset: Offset(0.0, 10 * (0.5 - _planeTween.transform(_planeController.value))),
            child: child,
          );
        },
      );
      return CustomRefreshIndicator(
        offsetToArmed: _offsetToArmed,
        autoRebuild: false,
        onStateChanged: (change) {
          if (change.didChange(
            from: IndicatorState.armed,
            to: IndicatorState.settling,
          )) {
            _startCloudAnimation();
            _startPlaneAnimation();
          }
          if (change.didChange(
            from: IndicatorState.loading,
          )) {
            _stopPlaneAnimation();
          }
          if (change.didChange(
            to: IndicatorState.idle,
          )) {
            _stopCloudAnimation();
          }
        },
        onRefresh: () => Future.delayed(const Duration(seconds: 3)),
        builder: (BuildContext context, Widget child, IndicatorController controller) {
          return AnimatedBuilder(
            animation: controller,
            child: child,
            builder: (context, child) {
              return Stack(
                clipBehavior: Clip.hardEdge,
                children: <Widget>[
                  if (!controller.side.isNone)
                    Container(
                      padding: const EdgeInsets.only(top: 70),
                      height: _offsetToArmed * controller.value,
                      color: const Color(0xFFe6e6e8),
                      width: double.infinity,
                      child: AnimatedBuilder(
                        animation: _cars.first.controller!,
                        builder: (BuildContext context, Widget? child) {
                          return Stack(
                            clipBehavior: Clip.hardEdge,
                            children: <Widget>[
                              for (final cloud in _cars)
                                Transform.translate(
                                  offset: Offset(
                                    ((screenWidth + cloud.width) * cloud.controller!.value) - cloud.width,
                                    cloud.dy * controller.value,
                                  ),
                                  child: OverflowBox(
                                    minWidth: cloud.width,
                                    minHeight: cloud.width,
                                    maxHeight: cloud.width,
                                    maxWidth: cloud.width,
                                    alignment: Alignment.topLeft,
                                    child: Image(
                                      //color: Colors.green,
                                      image: cloud.image,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),

                              /// plane
                              Center(
                                child: OverflowBox(
                                  maxWidth: 600,
                                  minWidth: 200,
                                  maxHeight: 300,
                                  minHeight: 150,
                                  alignment: Alignment.center,
                                  child: plane,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  Transform.translate(
                    offset: Offset(0.0, _offsetToArmed * controller.value),
                    child: child,
                  ),
                ],
              );
            },
          );
        },
        child: widget.child ?? Container(), // Provide a default child if widget.child is null
      );
    },
  );
}

}
