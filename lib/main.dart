import 'package:cic_production_pi/pages/loginpage.dart';
import 'package:cic_production_pi/pages/userprofile.dart';
import 'package:cic_production_pi/providers/machine.dart';
import 'package:cic_production_pi/providers/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart' as path;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isWeb = GetPlatform.isWeb;

  if (!isWeb) {
    final dir = await path.getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Hive.initFlutter('hive_db');
  }

  runApp(const MyApp());
  void configLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 5000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.yellow
      ..backgroundColor = Colors.green
      ..indicatorColor = Colors.yellow
      ..textColor = Colors.yellow
      ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = true
      ..dismissOnTap = false;
    //..customAnimation = CustomAnimation();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserData>.value(value: UserData()),
        ChangeNotifierProvider<MachineData>.value(value: MachineData()),
      ],
      child: Consumer<UserData>(
        builder: (context, _users, _) {
          _users.autoAuthenticate();
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'CIC Production',
            theme: ThemeData(
              // This is the theme of your application.
              //
              // Try running your application with "flutter run". You'll see the
              // application has a blue toolbar. Then, without quitting the app, try
              // changing the primarySwatch below to Colors.green and then invoke
              // "hot reload" (press "r" in the console where you ran "flutter run",
              // or simply save your changes to "hot reload" in a Flutter IDE).
              // Notice that the counter didn't reset back to zero; the application
              // is not restarted.
              primarySwatch: Colors.blue,
              fontFamily: 'Kanit-Regular',
            ),
            home: LoginPage(),
            // home: SecurityPointPage(),
            initialRoute: '/',
            routes: {
              LoginPage.routeName: (ctx) => LoginPage(),
              UserProfilePage.routeName: (ctx) => UserProfilePage(),
            },
            builder: EasyLoading.init(),
          );
        },
      ),
    );
  }
}
