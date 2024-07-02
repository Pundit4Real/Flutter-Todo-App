import 'package:flutter/material.dart';
import 'package:todo_master/screens/auth/login.dart';
import 'package:todo_master/screens/auth/registration.dart';
import 'package:todo_master/utils/constants.dart';
import 'package:todo_master/widgets/custom_scaffold.dart';
import 'package:todo_master/widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // This removes the back button
        // title: Text('Welcome to TaskMaster'),
        backgroundColor: Colors.transparent,
      ),
      child: Column(
        children: [
          Flexible(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Welcome to TodoMaster!\n',
                        style: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: '\nStay organized, stay productive. Join us now to manage your tasks effortlessly.',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign in',
                      onTap: () {
                        Navigator.of(context).push(_createRoute(LoginScreen()));
                      },
                      color: Colors.purple,
                      textColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign up',
                      onTap: () {
                        Navigator.of(context).push(_createRoute(RegisterScreen()));
                      },
                      color: Colors.white,
                      textColor: lightColorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const beginOffset = Offset(0.0, 1.0); // Slide from bottom
        const endOffset = Offset.zero;
        const curve = Curves.easeInOut;

        final tweenOffset = Tween(begin: beginOffset, end: endOffset)
            .chain(CurveTween(curve: curve));

        final tweenOpacity = Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tweenOffset),
          child: FadeTransition(
            opacity: animation.drive(tweenOpacity),
            child: child,
          ),
        );
      },
      transitionDuration: Duration(seconds: 1), // Adjust duration to make the transition slower
    );
  }
}
