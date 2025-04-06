import 'package:flutter/material.dart';
import 'package:giertag/components/settingsButton.dart';

class Devicesettings extends StatefulWidget {
  const Devicesettings({super.key});

  @override
  State<Devicesettings> createState() => _DevicesettingsState();
}

class _DevicesettingsState extends State<Devicesettings> {
  bool twoWayCallEnabled = false;
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.01),
              Settingsbutton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('IMEI Number'),
                          content: SizedBox(
                            width: screenWidth * 0.8,
                            child: Text('352812193148931',
                                style:
                                    TextStyle(fontSize: screenHeight * 0.02)),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Close'),
                            ),
                          ],
                        );
                      });
                },
                title: 'IMEI Number',
                iconLeading: Icons.watch_rounded,
                description: "Device's IMEI number",
                isNewPage: false,
              ),
              Settingsbutton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Network Provider'),
                          content: SizedBox(
                            width: screenWidth * 0.8,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenHeight * 0.02),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/icons/jio.png',
                                          height: screenHeight * 0.05,
                                        ),
                                        SizedBox(height: screenHeight * 0.01),
                                        Text('Jio',
                                            style: TextStyle(
                                                fontSize: screenHeight * 0.02)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenHeight * 0.02),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: AssetImage(
                                            'assets/icons/airtel.png',
                                          ),
                                          radius: screenHeight * 0.025,
                                        ),
                                        SizedBox(height: screenHeight * 0.01),
                                        Text('Airtel',
                                            style: TextStyle(
                                                fontSize: screenHeight * 0.02)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenHeight * 0.02),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: AssetImage(
                                            'assets/icons/vi.png',
                                          ),
                                          radius: screenHeight * 0.025,
                                        ),
                                        SizedBox(height: screenHeight * 0.01),
                                        Text('VI',
                                            style: TextStyle(
                                                fontSize: screenHeight * 0.02)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // Add selection logic
                              },
                              child: Text('Select'),
                            ),
                          ],
                        );
                      });
                },
                title: 'Network Provider',
                iconLeading: Icons.sim_card_rounded,
                description: "Specify the Network provider",
                isNewPage: false,
              ),
              Settingsbutton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Device Name'),
                        content: SizedBox(
                          width: screenWidth * 0.8,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Device Name',
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Save device name
                            },
                            child: Text('Save'),
                          ),
                        ],
                      );
                    },
                  );
                },
                title: 'Device Name',
                iconLeading: Icons.bluetooth_rounded,
                description: "Rename the device for easy identification",
                isNewPage: false,
              ),
              Settingsbutton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Profile Picture'),
                        content: SizedBox(
                          width: screenWidth * 0.8,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: screenHeight * 0.1,
                                    child: Icon(
                                      Icons.person_rounded,
                                      size: screenHeight * 0.1,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.edit_rounded,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.02),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // Add code to delete the profile picture
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Delete Picture',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
                title: 'Profile Picture',
                iconLeading: Icons.person_rounded,
                description: "Update or delete the child's profile picture.",
                isNewPage: false,
              ),
              Settingsbutton(
                onPressed: () {
                  Navigator.pushNamed(context, '/dnd');
                },
                title: 'DND Schedule',
                iconLeading: Icons.do_not_disturb_on_rounded,
                description:
                    "Schedule silent mode to mute the device during specific times, like school hours.",
                isNewPage: true,
              ),
              SizedBox(height: screenHeight * 0.01),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.call,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(
                  'Two-Way Call',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: screenHeight * 0.018,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                trailing: Switch(
                  value: twoWayCallEnabled,
                  onChanged: (value) {
                    setState(() {
                      twoWayCallEnabled = value;
                    });
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                subtitle: Text(
                    "If enabled, the child can make outgoing calls from the device.",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: screenHeight * 0.013,
                    )),
              ),
              Settingsbutton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        int selectedIndex = 2;

                        return StatefulBuilder(builder: (context, setState) {
                          return AlertDialog(
                            title: Text('Location Frequency'),
                            content: SizedBox(
                              height: screenHeight * 0.2,
                              width: screenWidth * 0.6,
                              child: ListWheelScrollView.useDelegate(
                                itemExtent: screenHeight * 0.05,
                                diameterRatio: 1.5,
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                                childDelegate: ListWheelChildBuilderDelegate(
                                  builder: (context, index) {
                                    // Your existing code for frequency options
                                    String text;
                                    switch (index) {
                                      case 0:
                                        text = '10 seconds';
                                        break;
                                      case 1:
                                        text = '30 seconds';
                                        break;
                                      case 2:
                                        text = '1 minute';
                                        break;
                                      case 3:
                                        text = '2 minutes';
                                        break;
                                      case 4:
                                        text = '5 minutes';
                                        break;
                                      default:
                                        text = 'Unknown';
                                    }
                                    return Center(
                                      child: Text(text,
                                          style: TextStyle(
                                              fontSize: screenHeight * 0.02)),
                                    );
                                  },
                                  childCount: 5,
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Location frequency updated')),
                                  );
                                },
                                child: Text('Save'),
                              ),
                            ],
                          );
                        });
                      });
                },
                title: 'Location Frequency',
                iconLeading: Icons.location_on_rounded,
                description: "Set the frequency of location updates",
                isNewPage: false,
              ),
              Settingsbutton(
                onPressed: () {
                  Navigator.pushNamed(context, '/contacts');
                },
                title: 'Contacts',
                iconLeading: Icons.contact_phone_rounded,
                description:
                    "Set up phone numbers that are allowed to call the device.",
                isNewPage: true,
              ),
              Settingsbutton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Find Device'),
                        content: Text('Ring the device to help locate it?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Ringing device to help locate it...'),
                                ),
                              );
                              // Add code to actually ring the device
                            },
                            child: Text('Yes'),
                          ),
                        ],
                      );
                    },
                  );
                },
                title: 'Find Device',
                iconLeading: Icons.location_searching_rounded,
                description: "Ring the device to help locate it if it's lost.",
                isNewPage: false,
              ),
              Settingsbutton(
                onPressed: () {
                  Navigator.pushNamed(context, '/geofence');
                },
                title: 'Setup Geofence',
                iconLeading: Icons.location_on_rounded,
                description:
                    "Set up geofences to receive alerts when the device enters or exits designated areas.",
                isNewPage: true,
              ),
              Settingsbutton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Send Message'),
                          content: SizedBox(
                            width: screenWidth * 0.8,
                            child: TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Message',
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // Add code to send message
                              },
                              child: Text('Send'),
                            ),
                          ],
                        );
                      });
                },
                title: 'Send Message',
                iconLeading: Icons.message_rounded,
                description:
                    "Send a short message to be displayed on the device screen.",
                isNewPage: false,
              ),
              Settingsbutton(
                onPressed: () {
                  Navigator.pushNamed(context, '/messages');
                },
                title: 'Read SMS',
                iconLeading: Icons.sms_rounded,
                description: "View SMS messages received on the device.",
                isNewPage: true,
              ),
              Settingsbutton(
                onPressed: () {
                  Navigator.pushNamed(context, '/calllog');
                },
                title: 'View call log',
                iconLeading: Icons.call_rounded,
                description: "View call log of the device.",
                isNewPage: true,
              ),
            ],
          ),
        ));
  }
}
