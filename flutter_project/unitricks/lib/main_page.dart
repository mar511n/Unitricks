import 'package:flutter/material.dart';
import 'backend.dart';
import 'main.dart';
import 'trick_widget.dart';

class MainPage extends StatefulWidget {
  final ParentFunctionCallback loginFunc;
  const MainPage({super.key, required this.loginFunc});
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _callParentLogin() async {
    widget.loginFunc(_usernameController.text, _passwordController.text);
  }

  @override
  void dispose() {
    // It is good practice to dispose of controllers when no longer in use
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _usernameController.text = username;
    _passwordController.text = passwd;
    return credentialsValidated ? 
      Center(child:
      Text('[random feed infos]')) :
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              // Add some spacing around the form
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Adjusts to widget’s content
                children: <Widget>[
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter your username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16), // Spacing between text fields
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true, // Hides typed text
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _callParentLogin,
                    child: const Text('Login'),
                  ),
                ],
              ),
            )
          ]
        )
      );

    //  Center(
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: <Widget>[
    //       if(!credentialsValidated) ...[
    //         UnicycleTrickWidget(
    //           name: "180 unispin",
    //           tags: ["180", "unispin"],
    //           description: "do a 180!!!! do a 180!!!! do a 180!!!! do a 180!!!! \n do a 180!!!! do a 180!!!! do a 180!!!!",
    //           proposedBy: "crivar istenson",
    //           videoLinks: ['jysWWisES7w', 'jysWWisES7e', 'jysWWisES7r'],
    //           startPositions: [';F;IFC;IBC',';F;IFC;'],
    //           endPositions: [';B;IFC;IBC',';F;;IBC'],
    //         ),
    //         //Text('[random feed infos]'),
    //       ],
    //       if(!credentialsValidated) ...[
    //         Padding(
    //           // Add some spacing around the form
    //           padding: const EdgeInsets.all(16.0),
    //           child: Column(
    //             mainAxisSize: MainAxisSize.min, // Adjusts to widget’s content
    //             children: <Widget>[
    //               TextField(
    //                 controller: _usernameController,
    //                 decoration: const InputDecoration(
    //                   labelText: 'Username',
    //                   hintText: 'Enter your username',
    //                   border: OutlineInputBorder(),
    //                 ),
    //               ),
    //               const SizedBox(height: 16), // Spacing between text fields
    //               TextField(
    //                 controller: _passwordController,
    //                 decoration: const InputDecoration(
    //                   labelText: 'Password',
    //                   hintText: 'Enter your password',
    //                   border: OutlineInputBorder(),
    //                 ),
    //                 obscureText: true, // Hides typed text
    //               ),
    //               const SizedBox(height: 24),
    //               ElevatedButton(
    //                 onPressed: _callParentLogin,
    //                 child: const Text('Login'),
    //               ),
    //             ],
    //           ),
    //         )
    //       ]
    //     ],
    //   ),
    // );
  }
}