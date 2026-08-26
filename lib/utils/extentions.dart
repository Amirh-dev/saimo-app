import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/helpers.dart';

extension OSInfo on BuildContext {
  String get os {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isLinux) {
      return 'linux';
    } else if (Platform.isMacOS) {
      return 'macos';
    } else if (kIsWeb) {
      return 'web';
    } else {
      return 'unknown';
    }
  }
}

extension ContextRouterExtension on BuildContext {
  Future<T?> to<T>(Widget child, {String? routeName}) {
    return Navigator.of(this).push<T>(
      PageRouteBuilder<T>(
        pageBuilder: (_, __, ___) => child,
        settings: RouteSettings(name: routeName),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (_, __, ___, c) => c,
      ),
    );
  }

  void toOff(Widget child, {String? routeName}) =>
      Navigator.of(this).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => child,
          transitionDuration: Duration.zero,
          settings: RouteSettings(name: routeName),
          reverseTransitionDuration: Duration.zero,
        ),
      );
  void toOffNamed(String path) => Navigator.of(this).pushReplacementNamed(path);

  void toOffAll(Widget child, {String? routeName}) =>
      Navigator.of(this).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (input) => child,
          settings: RouteSettings(name: routeName),
        ),
        (Route<dynamic> route) => false,
      );

  void toFirst() => Navigator.of(this).popUntil((route) => route.isFirst);

  void toNamed(String path, {Object? arguments}) =>
      Navigator.of(this).pushNamed(path, arguments: arguments);

  Future<bool> back() => Navigator.of(this).maybePop();
  void backTillFirst() => Navigator.of(this).popUntil((route) => route.isFirst);
  void backTill(String routeName, {String? secondRouteName}) =>
      Navigator.of(this).popUntil((route) {
        if (secondRouteName != null) {
          return (route.settings.name == routeName ||
              route.settings.name == secondRouteName);
        } else {
          return route.settings.name == routeName;
        }
      });
}

extension ContextDimensionsExtensions on BuildContext {
  double get deviceWidth => MediaQuery.of(this).size.width;
  double get deviceHeight => MediaQuery.of(this).size.height;
  bool get isDeviceMobile => MediaQuery.of(this).size.width < 600;
  bool get isDeviceTablet =>
      MediaQuery.of(this).size.width >= 600 &&
      MediaQuery.of(this).size.width < 900;
  bool get isDeviceLaptop =>
      MediaQuery.of(this).size.width >= 900 &&
      MediaQuery.of(this).size.width < 1200;
  bool get isDeviceBigScreen => MediaQuery.of(this).size.width >= 1200;

  double getResponsiveValue({
    double defaultValueMobile = 16.0,
    double defaultValueTablet = 20.0,
    double defaultValueLaptop = 24.0,
    double defaultValueBigScreen = 28.0,
  }) {
    double screenWidth = MediaQuery.of(this).size.width;

    if (screenWidth < 600) {
      return defaultValueMobile;
    } else if (screenWidth < 900) {
      return defaultValueTablet;
    } else if (screenWidth < 1200) {
      return defaultValueLaptop;
    } else {
      return defaultValueBigScreen;
    }
  }

  double percentWidth(double percent) =>
      (MediaQuery.of(this).size.width / 100) * percent;

  double percentHeight(double percent) =>
      (MediaQuery.of(this).size.height / 100) * percent;

  double percentWidthLimited(int percent, int max) =>
      (MediaQuery.of(this).size.width / 100) * percent > max
          ? max.toDouble()
          : (MediaQuery.of(this).size.width / 100) * percent;

  double percentHeightLimited(int percent, int max) =>
      (MediaQuery.of(this).size.height / 100) * percent > max
          ? max.toDouble()
          : (MediaQuery.of(this).size.height / 100) * percent;

  dynamic platformBaseValue({onAndroid, onIos, onWindows, onMac, onWeb}) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return onAndroid;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return onIos;
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      return onMac;
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      return onWindows;
    } else if (kIsWeb) {
      return onWeb;
    }
  }
}

extension WidgetUtilsExtensions on Widget {
  Widget responsiveWidth(BuildContext context, double factor) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(width: screenWidth * factor, child: this);
  }

  Widget responsiveHeight(BuildContext context, double factor) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(height: screenHeight * factor, child: this);
  }

  Widget vMargin(double margin) => Container(
        margin: EdgeInsets.symmetric(vertical: margin),
        child: this,
      );

  Widget hMargin(double margin) => Container(
        margin: EdgeInsets.symmetric(horizontal: margin),
        child: this,
      );

  Widget lMargin(double margin) => Container(
        margin: EdgeInsets.only(left: margin),
        child: this,
      );

  Widget rMargin(double margin) => Container(
        margin: EdgeInsets.only(right: margin),
        child: this,
      );

  Widget tMargin(double margin) => Container(
        margin: EdgeInsets.only(top: margin),
        child: this,
      );

  Widget bMargin(double margin) => Container(
        margin: EdgeInsets.only(bottom: margin),
        child: this,
      );

  Widget vPadding(double padding) => Container(
        padding: EdgeInsets.symmetric(vertical: padding),
        child: this,
      );

  Widget hPadding(double padding) => Container(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: this,
      );

  Widget lPadding(double padding) => Container(
        padding: EdgeInsets.only(left: padding),
        child: this,
      );

  Widget rPadding(double padding) => Container(
        padding: EdgeInsets.only(right: padding),
        child: this,
      );

  Widget tPadding(double padding) => Container(
        padding: EdgeInsets.only(top: padding),
        child: this,
      );

  Widget bPadding(double padding) => Container(
        padding: EdgeInsets.only(bottom: padding),
        child: this,
      );

  Widget sizedBox({double? height, double? width}) =>
      SizedBox(height: height, width: width, child: this);

  Widget get card => Card(child: this);
  Widget get expand => Expanded(child: this);
  Widget get center => Center(child: this);
}

extension FontSizeExtension on num {
  double get fs {
    const double baseWidth = 375.0;

    double screenWidth = MediaQueryData.fromView(
          WidgetsBinding.instance.platformDispatcher.views.single,
        ).size.width /
        MediaQueryData.fromView(
          WidgetsBinding.instance.platformDispatcher.views.single,
        ).devicePixelRatio;

    return (this * (screenWidth / baseWidth)).clamp(this * 0.85, this * 1.2);
  }
}

extension ContextUtils on BuildContext {
//   static final FToast fToast = FToast();

//   void showToast({
//     String title = 'اطلاعیه',
//     String description = '',
//     ToastType type = ToastType.normal,
//   }) {
//     Color backgroundColor;
//     Color textColor;
//      switch (type) {
//       case ToastType.error:
//         backgroundColor = AppColors.errorColor;
//         textColor = AppColors.lightErrorTextColor;
//          break;
//       case ToastType.warning:
//         backgroundColor = AppColors.warningColor;
//         textColor = AppColors.lightWarningTextColor;
//          break;
//       case ToastType.success:
//         backgroundColor = AppColors.successColor;
//         textColor = AppColors.lightSuccessTextColor;
//          break;
//       case ToastType.normal:
//         backgroundColor = AppColors.infoColor;
//         textColor = AppColors.lightInfoTextColor;
//          break;
//     }

//     final navigator = Navigator.maybeOf(this, rootNavigator: true);
//     final overlayState =
//         navigator?.overlay ?? Overlay.maybeOf(this, rootOverlay: true);
//     if (overlayState == null) return; // Avoid overlay-null crash
//     fToast.init(overlayState.context);

//     final toast = Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Directionality(
//         textDirection: TextDirection.rtl,
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Flexible(
//                   child: ReText(
//                     description,
//                     color: textColor,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                     overflow: TextOverflow.visible,
//                     textAlign: TextAlign.right,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );

//     vibrate();

//     fToast.removeCustomToast();

//     fToast.showToast(
//       child: toast,
//       gravity: ToastGravity.TOP,
//       toastDuration: const Duration(milliseconds: 2500),
//       positionedToastBuilder: (context, child, gravity) {
//         return Positioned(top: 50, left: 30, right: 30, child: child);
//       },
//     );
//   }
}
