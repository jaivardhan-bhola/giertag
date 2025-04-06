import 'package:flutter/material.dart';
import 'package:giertag/components/settingsButton.dart';
import 'package:giertag/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class Appsettings extends StatefulWidget {
  const Appsettings({super.key});

  @override
  State<Appsettings> createState() => _AppsettingsState();
}

class _AppsettingsState extends State<Appsettings> {
  bool batteryNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Center(
        child: Column(
      children: [
        SizedBox(height: screenHeight * 0.01),
        CircleAvatar(
          radius: screenHeight * 0.1,
          child: Text('GT',
              style: TextStyle(
                  fontSize: screenHeight * 0.1,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.surface)),
        ),
        SizedBox(height: screenHeight * 0.05),
        ListTile(
          leading: CircleAvatar(
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                Provider.of<ThemeProvider>(context).isDarkMode
                    ? Icons.dark_mode
                    : Icons.light_mode,
                key: ValueKey<bool>(
                    Provider.of<ThemeProvider>(context).isDarkMode),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          title: Text(
            'Theme',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: screenHeight * 0.018,
              fontWeight: FontWeight.normal,
            ),
          ),
          trailing: Switch(
            value: Provider.of<ThemeProvider>(context).isDarkMode,
            onChanged: (value) {
              Provider.of<ThemeProvider>(context, listen: false)
                  .toggleTheme();
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: screenHeight * 0.005),
        Settingsbutton(
          onPressed: () {},
          title: 'Subscription',
          description: 'Expires 31/Dec/2028',
          iconLeading: Icons.subscriptions_rounded,
          isNewPage: false,
        ),
        Settingsbutton(
            onPressed: () {
              Navigator.pushNamed(context, '/devicelist');
            },
            title: 'Devices',
            description: 'Add or Configure device settings',
            iconLeading: Icons.watch_rounded,
            isNewPage: true,
            ),
        Settingsbutton(
            onPressed: () {
              Navigator.pushNamed(context, '/addDevice');
            },
            title: 'Add/Remove Devices',
            description: 'Add or remove a GPS tracking device from the app',
            iconLeading: Icons.location_on_rounded,
            isNewPage: true),
        ListTile(
          subtitle: Text(
            'Get notified when the device battery drops below 20%.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: screenHeight * 0.013,
            ),
          ),
          leading: CircleAvatar(
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.battery_charging_full,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            'Battery Notifications',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: screenHeight * 0.018,
              fontWeight: FontWeight.normal,
            ),
          ),
          trailing: Switch(
            value: batteryNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                batteryNotificationsEnabled = value;
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        Settingsbutton(
            onPressed: () {
              Navigator.pushNamed(context, '/customerSupport');
            },
            title: 'Customer Support',
            description:
                'Connect instantly with customer support for assistance via chat.',
            iconLeading: Icons.chat_rounded,
            isNewPage: true),
      ],
    ));
  }
}
