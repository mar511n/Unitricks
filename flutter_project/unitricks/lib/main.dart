import 'package:flutter/material.dart';
import 'backend.dart';
import 'main_page.dart';
import 'tricks_page.dart';
import 'users_page.dart';

const appName = "Unitricks";
const subPageNames = ["Main Page", "Tricks", "Users"];
const subPageIcons = [Icon(Icons.home), Icon(Icons.bolt), Icon(Icons.people)];

// TODO: add hover hints for buttons

typedef ParentFunctionCallback = void Function(String un, String pw);

void main() async {
  // load username and password on startup
  WidgetsFlutterBinding.ensureInitialized();
  username = await storage.read(key: 'username') ?? "";
  passwd = await storage.read(key: 'password') ?? "";

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorSchemeSeed: Colors.blue,
  );
  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorSchemeSeed: Colors.green,
  );
  int _selectedIndex = 0;

  Widget makePage(int idx) {
    switch (idx) {
      case 0:
        return MainPage(loginFunc: logIn);
      case 1:
        return TricksPage();
      case 2:
        return UsersPage();
      default:
        return MainPage(loginFunc: logIn);
    }
  }

  void _selectPage(int index, {navpop=true}) {
    if (navpop) {
      _navigatorKey.currentState!.pop();
    }
    setState(() {

      _selectedIndex = index;
    });
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    });
  }

  ThemeData currentTheme() {
    return (_themeMode == ThemeMode.light) ? lightTheme : darkTheme;
  }

  void logIn(String un, pw) async {
    username = un;
    passwd = pw;
    final retVal = await tryLogIn();
    setState(() {});
    makeNotification(credentialsValidated ? 'Login successful' : 'Login failed: $retVal');
  }

  void logOut() async {
    credentialsValidated = false;
    //resetCredentials();
    setState(() {});
  }

  void makeNotification(String text) {
    _scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(content: Text(text)),);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tiles = [];
    tiles.add(
      DrawerHeader(
        decoration: BoxDecoration(
          color: currentTheme().canvasColor,
        ),
        child: Text(
          'Menu',
          style: TextStyle(fontSize: 24, color: currentTheme().textTheme.headlineMedium!.color),
        ),
      ),
    );

    for (int i = 1; i < subPageNames.length; i++) {
      tiles.add(
        ListTile(
          leading: subPageIcons[i],
          title: Text(subPageNames[i]),
          onTap:() {
            if(credentialsValidated) {
              _selectPage(i);
            }else{
              _selectPage(0);
              makeNotification("To Access '${subPageNames[i]}' you have to log in first...");
            }
          },
          selected: _selectedIndex==i,
        ),
      );
    }

    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      navigatorKey: _navigatorKey,
      title: appName,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 8,
            children: [
              TextButton(onPressed: () => _selectPage(0,navpop: false), child: Text(appName, style: TextStyle( fontSize: 30))),
              Text(subPageNames[_selectedIndex], style : TextStyle( fontSize: 30)),
            ],
          ),
          actions: [
            Text(credentialsValidated ? "Logged in as $username" : ""),
            if (credentialsValidated) ...[IconButton(onPressed: logOut, icon: Icon(Icons.logout))] ,//IconButton(onPressed: onLogIn, icon: Icon(Icons.login)),
            IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: _toggleTheme,
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: tiles,
          ),
        ),
        body: makePage(_selectedIndex),
      ),
    );
  }
}