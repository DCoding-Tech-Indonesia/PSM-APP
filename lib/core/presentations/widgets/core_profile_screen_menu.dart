import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travis/core/storage/shared_preferences.dart';
import 'package:travis/core/theme/core_styling.dart';

class CoreProfileScreenMenu extends StatefulWidget {
  final SharedPreferencesService sharedPreferencesService;

  const CoreProfileScreenMenu({
    super.key,
    required this.sharedPreferencesService,
  });

  @override
  State<CoreProfileScreenMenu> createState() => _CoreProfileScreenMenuState();
}

class _CoreProfileScreenMenuState extends State<CoreProfileScreenMenu> {
  late bool _allowBiometric;

  @override
  void initState() {
    super.initState();
    _allowBiometric = widget.sharedPreferencesService.getBiometric();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    context.go('/portal');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        width: .5,
                        color: CoreStyling.primaryColor,
                      ),
                    ),
                    child: Icon(Icons.exit_to_app),
                  ),
                ),
              ],
            ),
          ),
          Text("PROFILE"),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.fingerprint),
                            Text("Biometric"),
                          ],
                        ),
                      ),
                      Switch(
                        value: _allowBiometric,
                        activeThumbColor: CoreStyling.primaryColor,
                        onChanged: (bool value) {
                          widget.sharedPreferencesService.toggleBiometric(
                            !_allowBiometric,
                          );
                          setState(() {
                            _allowBiometric = !_allowBiometric;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
