import 'package:flutter/material.dart';
import 'package:giertag/pages/location/geofence.dart';
import 'package:giertag/pages/settings/addDevice.dart';
import 'package:giertag/pages/settings/callLog.dart';
import 'package:giertag/pages/settings/contacts.dart';
import 'package:giertag/pages/settings/customerSupport.dart';
import 'package:giertag/pages/settings/deviceList.dart';
import 'package:giertag/pages/settings/deviceSettings.dart';
import 'package:giertag/pages/settings/dndSchedules.dart';
import 'package:giertag/pages/settings/messages.dart';
import 'package:giertag/start.dart';
import 'package:giertag/theme/dark.dart';
import 'package:giertag/theme/light.dart';
import 'package:giertag/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDark = prefs.getBool('isDark') ?? false;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => ThemeProvider(isDark ? darkmode : lightmode)),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  static const String DeviceListRoute = '/devicelist';
  static const String HomeRoute = '/';
  static const String DeviceSettings = '/deviceSettings';
  static const String DNDRoute = '/dnd';
  static const String ContactsRoute = '/contacts';
  static const String MessagesRoute = '/messages';
  static const String CallLogRoute = '/calllog';
  static const String AddDeviceRoute = '/addDevice';
  static const String GeoFenceRoute = '/geofence';
  static const String CustomerSupportRoute = '/customerSupport';

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      initialRoute: HomeRoute,
      routes: {
        '/' : (context) => Start(),
        '/devicelist': (context) => Devicelist(),
        '/deviceSettings': (context) => Devicesettings(),
        '/dnd': (context) => Dndschedules(),
        '/contacts': (context) => Contacts(),
        '/messages': (context) => Messages(),
        '/calllog': (context) => Calllog(),
        '/addDevice': (context) => Adddevice(),
        '/geofence': (context) => Geofence(),
        '/customerSupport': (context) => Customersupport(),
      },

    );
  }
}
