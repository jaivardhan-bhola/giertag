import 'package:flutter/material.dart';
import 'package:giertag/components/settingsButton.dart';

class Devicelist extends StatefulWidget {
  const Devicelist({super.key});

  @override
  State<Devicelist> createState() => _DevicelistState();
}

class _DevicelistState extends State<Devicelist> {
  final devicelist = [
    'Device 1',
    'Device 2',
    'Device 3',
    'Device 4',
    'Device 5',
    'Device 6',
    'Device 7',
    'Device 8',
    'Device 9',
    'Device 10',
    'Device 11',
    'Device 12',
    'Device 13',
    'Device 14',
    'Device 15',
    'Device 16',
    'Device 17',
    'Device 18',
    'Device 19',
    'Device 20',
  ];
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
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
      body: Padding(
        padding: EdgeInsets.only(top: screenHeight * 0.01),
        child: ListView.builder(
          itemCount: devicelist.length,
          itemBuilder: (context, index) {
            return Settingsbutton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/deviceSettings',
                );
              },
              title: devicelist[index],
              iconLeading: Icons.devices_other,
              isNewPage: true,
            );
          },
        ),
      ),
    );
  }
}
