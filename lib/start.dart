import 'package:flutter/material.dart';
import 'package:giertag/pages/location/locationHistory.dart';
import 'package:giertag/pages/location/mainLocation.dart';
import 'package:giertag/pages/settings/appSettings.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  int _currentIndex = 0;
  List children = [
    Mainlocation(),
    Locationhistory(),
    Appsettings(),
  ];
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Gier',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: screenHeight * 0.03)),
            Text('Tag',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenHeight * 0.03)),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            children[_currentIndex],
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: _currentIndex == 0
                      ? Icon(Icons.home_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: screenHeight * 0.04)
                      : Icon(Icons.home_outlined,
                          size: screenHeight * 0.04,
                          color: Theme.of(context).colorScheme.onSurface),
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0;
                    });
                  },
                ),
                IconButton(
                  icon: _currentIndex == 1
                      ? Icon(Icons.location_on,
                          color: Theme.of(context).colorScheme.primary,
                          size: screenHeight * 0.04)
                      : Icon(Icons.location_on_outlined,
                          size: screenHeight * 0.04,
                          color: Theme.of(context).colorScheme.onSurface),
                  onPressed: () {
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                ),
                IconButton(
                  icon: _currentIndex == 2
                      ? Icon(Icons.settings_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: screenHeight * 0.04)
                      : Icon(Icons.settings_outlined,
                          size: screenHeight * 0.04,
                          color: Theme.of(context).colorScheme.onSurface),
                  onPressed: () {
                    setState(() {
                      _currentIndex = 2;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }
}
