import 'package:crud_firebase/widgets/auth_background_c1.dart';
import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 81, 34, 237),
      width: double.infinity,
      height: double.infinity,
      child: Stack(children: [
        AuthBackgorundC1(),
        SafeArea(
            child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 10),
          child: const Icon(
            Icons.shop,
            color: Colors.white,
            size: 100,
          ),
        )),
        child,
      ]),
    );
  }
}
