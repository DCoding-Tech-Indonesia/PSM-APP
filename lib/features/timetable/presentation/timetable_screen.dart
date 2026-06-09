import 'package:flutter/material.dart';
import 'package:psm_mobile/core/presentations/widgets/core_header.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CoreHeader(
              title: "Time Table",
              customBgColor: Colors.white,
              withBorder: true,
            ),
            Center(child: Text("TOLONG MAU DI ISI SEPERTI APA", textAlign: TextAlign.center,style: TextStyle(fontSize: 100, fontWeight: FontWeight.w900),)),
          ],
        ),
      ),
    );
  }
}
