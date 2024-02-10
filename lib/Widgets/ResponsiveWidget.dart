import 'package:flutter/material.dart';
//from https://github.com/ptyagicodecamp/x-flutter-landingpage/blob/native/landingpage/lib/utils/responsive_widget.dart

/*
Large Screen: width > 1200px
Medium Screen: 800 < width < 1200px
Small Screen: width < 800px

 */

class ResponsiveWidget extends StatelessWidget {
  final Widget largeScreen;
  final Widget? mediumScreen;
  final Widget? smallScreen;

  const ResponsiveWidget(
      {Key? key,
      required this.largeScreen,
      this.mediumScreen,
      this.smallScreen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //selects widget most appropriate for the screen size
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 1200) {
        return largeScreen;
      } else if (constraints.maxWidth > 800 && constraints.maxWidth < 1200) {
        //if medium screen not available, then return large screen
        return mediumScreen ?? largeScreen;
      } else {
        //if small screen implementation not available, then return large screen
        return smallScreen ?? largeScreen;
      }
    });
  }

  //Static methods allows them to be accessed by other widgets

  //Large Screen: width > 1200px
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200;
  }

  //Medium Screen: 800 < width < 1200px
  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 800 &&
        MediaQuery.of(context).size.width < 1200;
  }

  //Small Screen: width < 800px
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 800;
  }
}
