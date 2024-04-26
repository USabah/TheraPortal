import 'package:flutter/material.dart';
import 'package:theraportal/Pages/AccountTypePage.dart';
import 'package:theraportal/Pages/SignInPage.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveWidget(
      largeScreen: LargeScreen(),
    );
  }
}

class LargeScreen extends StatelessWidget {
  const LargeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Spacer(), // Pushes the logo 1/4 down from the top
            // Logo or App Name
            const Text(
              "TheraPortal",
              style: logoText,
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: SizedBox(
                width: size.width * buttonWidthFactor, //332
                height: size.height * buttonHeightFactor, //45
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SignInPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Styles.beige,
                  ),
                  child: const Text(
                    "Login",
                    style: buttonTextStyle,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: size.width * buttonWidthFactor,
              height: size.height * buttonHeightFactor,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AccountTypePage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Styles.beige,
                ),
                child: const Text(
                  "Register",
                  style: buttonTextStyle,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class LandingPage extends StatelessWidget {
  static const Key pageKey = Key("Landing Page");

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: pageKey,
      body: Body(),
    );
  }
}
