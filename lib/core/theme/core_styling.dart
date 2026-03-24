import 'package:flutter/material.dart';

class CoreStyling {

  static const Color primaryColor = Color(0xFF2376D9);
  static const Color secondaryColor = Color(0xFFFFBC42);
  static const Color accentOneColor = Color(0xFFD81159);
  static const Color accentTwoColor = Color(0xFF8F2D56);

  static const LinearGradient coreActiveButtonGradient = LinearGradient(
    colors: [
      Color(0xFF2376D9),
      Color(0xFF094C9C),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient coreDisableButtonGradient = LinearGradient(
    colors: [
      Color(0xFF686868),
      Color(0xFF3D3D3D),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );-

  static const BorderRadius coreButtonRadius = BorderRadius.all(
    Radius.circular(10),
  );

}