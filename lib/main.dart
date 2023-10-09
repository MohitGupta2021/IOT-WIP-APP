// // // // /*
// // // //  * Package : mqtt_client
// // // //  * Author : S. Hamblett <steve.hamblett@linux.com>
// // // //  * Date   : 10/07/2021
// // // //  * Copyright :  S.Hamblett
// // // //  *
// // // //  */

// // // // import 'dart:async';
// // // // import 'dart:io';
// // // // import 'package:mqtt_client/mqtt_server_client.dart';
// // // // import 'package:mqtt_client/mqtt_client.dart';

// // // // Future<void> main() async {
// // // //   const url = 'a1hjtipwb9wtw6-ats.iot.ap-south-1.amazonaws.com';
// // // //   const port = 8883;
// // // //   const clientId = '12';

// // // //   final client = MqttServerClient.withPort(url, clientId, port);

// // // //   client.secure = true;
// // // //   client.keepAlivePeriod = 20;
// // // //   client.setProtocolV311();
// // // //   client.logging(on: false);

// // // //   // Remove Flutter-specific code related to loading assets
// // // //   // ByteData rootCA = await rootBundle.load('assets/certs/AmazonRootCA1.pem');
// // // //   // ByteData deviceCert = await rootBundle.load('assets/certs/c23b9b1b7672c7d4e66148b84febeed1098f9884a6218a84de230b3855187daa-certificate.pem.crt');
// // // //   // ByteData privateKey = await rootBundle.load('assets/certs/c23b9b1b7672c7d4e66148b84febeed1098f9884a6218a84de230b3855187daa-private.pem.key');

// // // //   // Load certificates from local paths (modify these paths according to your setup)
// // // //   final rootCA = File('assets/cert/AmazonRootCA1.pem');
// // // //   final deviceCert = File('assets/cert/c23b9b1b7672c7d4e66148b84febeed1098f9884a6218a84de230b3855187daa-certificate.pem.crt');
// // // //   final privateKey = File('assets/cert/c23b9b1b7672c7d4e66148b84febeed1098f9884a6218a84de230b3855187daa-private.pem.key');

// // // //   SecurityContext context = SecurityContext.defaultContext;
// // // //   context.setClientAuthoritiesBytes(await rootCA.readAsBytes());
// // // //   context.useCertificateChainBytes(await deviceCert.readAsBytes());
// // // //   context.usePrivateKeyBytes(await privateKey.readAsBytes());

// // // //   client.securityContext = context;

// // // //   final connMess = MqttConnectMessage()
// // // //       .withClientIdentifier(clientId)
// // // //       .startClean();
// // // //   client.connectionMessage = connMess;

// // // //   try {
// // // //     print('MQTT client connecting to AWS IoT using certificates....');
// // // //     await client.connect();
// // // //   } on Exception catch (e) {
// // // //     print('MQTT client exception - $e');
// // // //     client.disconnect();
// // // //     exit(-1);
// // // //   }

// // // //   if (client.connectionStatus!.state == MqttConnectionState.connected) {
// // // //     print('MQTT client connected to AWS IoT');

// // // //     await MqttUtilities.asyncSleep(1);
// // // //     const topic = '/test/topic';
// // // //     final builder = MqttClientPayloadBuilder();
// // // //     builder.addString('Hello World');
// // // //     client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);

// // // //     client.subscribe(topic, MqttQos.atLeastOnce);

// // // //     client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
// // // //       final recMess = c[0].payload as MqttPublishMessage;
// // // //       final pt =
// // // //           MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
// // // //       print(
// // // //           'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
// // // //       print('');
// // // //     });
// // // //   } else {
// // // //     print(
// // // //         'ERROR MQTT client connection failed - disconnecting, state is ${client.connectionStatus!.state}');
// // // //     client.disconnect();
// // // //   }

// // // //   print('Sleeping....');
// // // //   await MqttUtilities.asyncSleep(10);

// // // //   print('Disconnecting');
// // // //   client.disconnect();
// // // // }


import 'dart:async';
import 'dart:convert'; // Add this import for JSON parsing
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:percent_indicator/circular_percent_indicator.dart'; // Add this import

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Autoswitch Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key? key}) : super(key: key);

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final TextEditingController messageController = TextEditingController();
//   late MqttServerClient client;
//   String receivedMessage = '';
//   String subscribeData = '';
// bool switchState = false; // Initial switch state

//   @override
//   void initState() {
//     super.initState();
//     setupMqtt();
//   }

//   Future<void> setupMqtt() async {
//     const url = 'a1hjtipwb9wtw6-ats.iot.ap-south-1.amazonaws.com';
//     const port = 8883;
//     const clientId = '12';

//     client = MqttServerClient.withPort(url, clientId, port)
//       ..port = port
//       ..secure = true
//       ..logging(on: false);

//     ByteData rootCAData = await rootBundle.load('assets/cert/RootCA.pem');
//     ByteData deviceCertData =
//         await rootBundle.load('assets/cert/DeviceCertificate.crt');
//     ByteData privateKeyData = await rootBundle.load('assets/cert/Private.key');

//     SecurityContext context = SecurityContext.defaultContext
//       ..setClientAuthoritiesBytes(Uint8List.view(rootCAData.buffer))
//       ..useCertificateChainBytes(Uint8List.view(deviceCertData.buffer))
//       ..usePrivateKeyBytes(Uint8List.view(privateKeyData.buffer));

//     client.securityContext = context;

//     final connMess =
//         MqttConnectMessage().withClientIdentifier(clientId).startClean();
//     client.connectionMessage = connMess;

//     try {
//       print('MQTT client connecting to AWS IoT using certificates....');
//       await client.connect();
//       print('MQTT client connected to AWS IoT');

//       const subscribeTopic = 'data/sub';
//       client.subscribe(subscribeTopic, MqttQos.atLeastOnce);

//       client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
//         final recMess = c[0].payload as MqttPublishMessage;
//         final pt =
//             MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
//         setState(() {
//           subscribeData = pt;
//         });
//       });

//       client.onSubscribed = (String topic) {
//         print('Subscribed to topic: $topic');
//       };

//       client.onSubscribeFail = (String topic) {
//         print('Failed to subscribe to topic: $topic');
//       };
//     } on Exception catch (e) {
//       print('MQTT client exception - $e');
//       client.disconnect();
//     }
//   }

//   Future<void> publishMessage() async {
//     final topic = '/test/topic';
//     final builder = MqttClientPayloadBuilder();
//     builder.addString(messageController.text);
// builder.addString('{"states": ${switchState ? 1 : 0}}'); // Send JSON message based on switch state

//     client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
//   }

//   @override
//   void dispose() {
//     messageController.dispose();
//     client.disconnect();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     int waterLevel = 0; // Initialize water level

//     try {
//       waterLevel = json.decode(subscribeData)['waterlevel'];
//     } catch (e) {
//       // Handle JSON parsing error
//       print(e);
//     }
//     return Scaffold(
//   appBar: AppBar(
//     title: Text('IOT APP'),
//     backgroundColor: Colors.teal,
//   ),
//   backgroundColor: Colors.white,
//   body: SingleChildScrollView(
//     child: Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Text(
//             'Subscribe Data:',
//             style: TextStyle(fontSize: 20, color: Colors.black),
//           ),
//           Text(
//             subscribeData,
//             style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
//           ),
//           SizedBox(height: 20),
//           Container(
//             width: 200,
//             height: 200,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.transparent,
//               border: Border.all(color: Colors.blue, width: 10.0),
//             ),
//             child: Center(
//               child: Text(
//                 '$waterLevel%',
//                 style: TextStyle(fontSize: 24, color: Colors.blue),
//               ),
//             ),
//           ),
//           SizedBox(height: 20),
//           Container(
//             width: 250,
//             child: TextField(
//               controller: messageController,
//               decoration: InputDecoration(
//                 labelText: 'Message to Publish',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ),
//           SizedBox(height: 20),
//               SwitchListTile(
//                 title: Text(switchState ? 'ON' : 'OFF'),
//                 value: switchState,
//                 onChanged: (value) {
//                   setState(() {
//                     switchState = value;
//                   });
//                 },
//                 activeColor: Colors.yellow,
//                 inactiveThumbColor: Colors.red,
//               ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               publishMessage();
//               messageController.clear();
//             },
//             style: ElevatedButton.styleFrom(
//               primary: Colors.teal,
//             ),
//             child: Text(
//               'Publish Message',
//               style: TextStyle(fontSize: 18, color: Colors.white),
//             ),
//           ),
//           SizedBox(height: 130), // Add space at the bottom to prevent overflow
//         ],
//       ),
//     ),
//   ),
// );

//   }
// }


import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The IOT APP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // Define your page views for Home and Settings
  final List<Widget> _pages = [
    HomeScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('IOT APP'),
      // ),
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}



class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController messageController = TextEditingController();
  late MqttServerClient client;
  String receivedMessage = '';
  String subscribeData = '';
bool switchState = false; // Initial switch state
bool switchState2=false;
  @override
  void initState() {
    super.initState();
    setupMqtt();
  }

  Future<void> setupMqtt() async {
    const url = 'a1hjtipwb9wtw6-ats.iot.ap-south-1.amazonaws.com';
    const port = 8883;
    const clientId = '12';

    client = MqttServerClient.withPort(url, clientId, port)
      ..port = port
      ..secure = true
      ..logging(on: false);

    ByteData rootCAData = await rootBundle.load('assets/cert/RootCA.pem');
    ByteData deviceCertData =
        await rootBundle.load('assets/cert/DeviceCertificate.crt');
    ByteData privateKeyData = await rootBundle.load('assets/cert/Private.key');

    SecurityContext context = SecurityContext.defaultContext
      ..setClientAuthoritiesBytes(Uint8List.view(rootCAData.buffer))
      ..useCertificateChainBytes(Uint8List.view(deviceCertData.buffer))
      ..usePrivateKeyBytes(Uint8List.view(privateKeyData.buffer));

    client.securityContext = context;

    final connMess =
        MqttConnectMessage().withClientIdentifier(clientId).startClean();
    client.connectionMessage = connMess;

    try {
      print('MQTT client connecting to AWS IoT using certificates....');
      await client.connect();
      print('MQTT client connected to AWS IoT');

      const subscribeTopic = 'data/sub';
      client.subscribe(subscribeTopic, MqttQos.atLeastOnce);

      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final recMess = c[0].payload as MqttPublishMessage;
        final pt =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        setState(() {
          subscribeData = pt;
        });
      });

      client.onSubscribed = (String topic) {
        print('Subscribed to topic: $topic');
      };

      client.onSubscribeFail = (String topic) {
        print('Failed to subscribe to topic: $topic');
      };
    } on Exception catch (e) {
      print('MQTT client exception - $e');
      client.disconnect();
    }
  }

  Future<void> publishMessage() async {
    final topic = '/test/topic';
    final builder = MqttClientPayloadBuilder();
    builder.addString(messageController.text);
builder.addString('{"states": ${switchState ? 1 : 0}}'); // Send JSON message based on switch state

    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }
  Future<void> publishMessage2() async {
    final topic = '/test/topic';
    final builder = MqttClientPayloadBuilder();
    builder.addString(messageController.text);
builder.addString('{"states2": ${switchState2 ? 1 : 0}}'); // Send JSON message based on switch state

    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  @override
  void dispose() {
    messageController.dispose();
    client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double waterLevel = 0.0; // Initialize water level
int unixTime =0;
String formattedDateTime;
    try {
      Map<String, dynamic> jsonData = json.decode(subscribeData);
      waterLevel = jsonData['waterlevel'];
      unixTime = jsonData['unix'];
       formattedDateTime =DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(unixTime * 1000));
    } catch (e) {
      // Handle JSON parsing error
      print(e);
    }
    return Scaffold(
  
  appBar: PreferredSize(
        preferredSize: Size.fromHeight(20.0), // Set your preferred height here
        child: AppBar(
          title: Text('DEVICE PARAMETERS'),
          backgroundColor: Colors.teal,
        ),
      ),
  backgroundColor: Colors.white,
  body: SingleChildScrollView(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Subscribe Data:',
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          Text(
            subscribeData,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          SizedBox(height: 20),
          Container(
  width: 220,
  height: 220,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.transparent,
    border: Border.all(color: Colors.blueAccent, width: 10.0),
  ),
  child: Center(
    child: Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: CircularProgressIndicator(
            value: waterLevel / 100,
            strokeWidth: 10.0,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getColorForWaterLevel(waterLevel),
            ),
          ),
        ),
        // Container(
        //   width: 2, // Width of the marker line
        //   height: 100, // Height of the marker line
        //   decoration: BoxDecoration(
        //     color: Colors.red, // Color of the marker line
        //     borderRadius: BorderRadius.circular(2),
        //   ),
        //   transform: Matrix4.translationValues(0.0, -100.0 + (waterLevel / 100 * 100), 0.0), // Adjust the position of the marker
        // ),
        Text(
          _getWaterLevelText(waterLevel),
          style: TextStyle(fontSize: 15, color: const Color.fromARGB(255, 243, 243, 33)),
        ),
      ],
    ),
  ),
),



          // Container(
          //   width: 200,
          //   height: 200,
          //   decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //     color: Colors.transparent,
          //     border: Border.all(color: Colors.blue, width: 10.0),
          //   ),
          //   child: Center(
          //     child: Text(
          //       '$waterLevel%',
          //       style: TextStyle(fontSize: 24, color: Colors.blue),
          //     ),
          //   ),
          // ),
          
              

 SizedBox(height: 20),
              

SwitchListTile(
  title: Text('Switch 1: ${switchState ? 'ON' : 'OFF'}'),
  value: switchState,
  onChanged: (value) {
    setState(() {
      switchState = value;
      publishMessage(); // Call publishMessage when the switch state changes
    });
  },
  activeColor: Colors.yellow,
  inactiveThumbColor: Colors.red,
),
SwitchListTile(
  title: Text('Switch 2: ${switchState2 ? 'ON' : 'OFF'}'),
  value: switchState2,
  onChanged: (value) {
    setState(() {
      switchState2 = value;
      publishMessage2(); // Call publishMessage2 when the switch state changes
    });
  },
  activeColor: Colors.yellow,
  inactiveThumbColor: Colors.red,
),
Center(
        child: DataTable(
          columns: <DataColumn>[
            DataColumn(
              label: Text(
                'Property',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Value',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
          rows: <DataRow>[
            DataRow(
              cells: <DataCell>[
                DataCell(Text('Water Level')),
                DataCell(Text('$waterLevel')),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                DataCell(Text('Unix Time')),
                DataCell(Text('$formattedDateTime',overflow: TextOverflow.ellipsis,maxLines: 2,softWrap: true,)),
                
              
              ],
            ),
            // Add more rows for additional data properties if needed
          ],
        ),
      ),
    
          // SizedBox(height: 20),
          // ElevatedButton(
          //   onPressed: () {
          //     publishMessage();
          //     messageController.clear();
          //   },
          //   style: ElevatedButton.styleFrom(
          //     primary: Colors.teal,
          //   ),
          //   child: Text(
          //     'Publish Message',
          //     style: TextStyle(fontSize: 18, color: Colors.white),
          //   ),
          // ),
          SizedBox(height: 130), // Add space at the bottom to prevent overflow
        ],
      ),
    ),
  ),
);

  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedOption = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          _buildListTile(Icons.person, 'Profile', 'Manage your profile', () {
            // Navigate to the "Profile" page when the list tile is tapped
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProfilePage(), // Create ProfilePage
              ),
            );
          }),
          _buildListTile(Icons.settings, 'Device Settings', 'Configure device settings', () {
            // Remap to the main settings menu when "Settings" is pressed
             Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DevicePage(), // Create ProfilePage
              ),
            );
            
          }),
          _buildListTile(Icons.help, 'Help & Support', 'Get help and support', () {
            // Navigate to the "Help & Support" page when the list tile is tapped
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => HelpSupportPage(), // Create HelpSupportPage
              ),
            );
          }),
          _buildListTile(Icons.card_giftcard, 'Refer and Win', 'Refer friends and earn rewards', () {
            // Navigate to the "Refer and Win" page when the list tile is tapped
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ReferAndWinPage(), // Create ReferAndWinPage
              ),
            );
          }),
        ],
      ),
      bottomSheet: selectedOption.isNotEmpty
          ? Container(
              color: Colors.grey[200],
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Selected Option: $selectedOption',
                style: TextStyle(fontSize: 18),
              ),
            )
          : null,
    );
  }

  ListTile _buildListTile(IconData icon, String title, String subtitle, Function() onTapFunction) {
    return ListTile(
      leading: Icon(icon), // Add an icon to the ListTile
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {
        setState(() {
          selectedOption = title;
        });
        onTapFunction(); // Call the provided onTap function
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Center(
        child: Text('This is the Profile Page'),
      ),
    );
  }
}
class DevicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DevicePage Page'),
      ),
      body: Center(
        child: Text('This is the  PageDevice'),
      ),
    );
  }
}

class HelpSupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support Page'),
      ),
      body: Center(
        child: Text('This is the Help & Support Page'),
      ),
    );
  }
}

class ReferAndWinPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Refer and Win Page'),
      ),
      body: Center(
        child: Text('This is the Refer and Win Page'),
      ),
    );
  }
}
// Helper functions to determine color and text based on water level
Color _getColorForWaterLevel(double waterLevel) {
  if (waterLevel >= 90.0) {
    return Colors.green; // Tank is full
  } else if (waterLevel >= 60.0) {
    return Colors.yellow; // Medium level
  } else if (waterLevel >= 30.0) {
    return Colors.orange; // Low level
  } else {
    return Colors.red; // Very low level
  }
}

String _getWaterLevelText(double waterLevel) {
  if (waterLevel >= 90.0) {
    return 'Tank is Full';
  } else if (waterLevel >= 60.0) {
    return 'Medium Level';
  } else if (waterLevel >= 30.0) {
    return 'Low Level';
  } else {
    return 'Very Low Level';
  }
}

// class SettingsScreen extends StatefulWidget {
//   @override
//   _SettingsScreenState createState() => _SettingsScreenState();
// }
// class _SettingsScreenState extends State<SettingsScreen> {
//   String selectedOption = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Settings'),
//       ),
//       body: ListView(
//         children: <Widget>[
//           _buildListTile(Icons.person, 'Profile', 'Manage your profile'),
//           _buildListTile(Icons.settings, 'Device Settings', 'Configure device settings'),
//           _buildListTile(Icons.help, 'Help & Support', 'Get help and support'),
//           _buildListTile(Icons.card_giftcard, 'Refer and Win', 'Refer friends and earn rewards'),
//         ],
//       ),
//       bottomSheet: selectedOption.isNotEmpty
//           ? Container(
//               color: Colors.grey[200],
//               padding: EdgeInsets.all(16.0),
//               child: Text(
//                 'Selected Option: $selectedOption',
//                 style: TextStyle(fontSize: 18),
//               ),
//             )
//           : null,
//     );
//   }

//   ListTile _buildListTile(IconData icon, String title, String subtitle) {
//     return ListTile(
//       leading: Icon(icon), // Add an icon to the ListTile
//       title: Text(title),
//       subtitle: Text(subtitle),
//       onTap: () {
//         setState(() {
//           selectedOption = title;
//         });
//       },
//     );
//   }
// }


// class SettingsScreen extends StatefulWidget {
//   @override
//   _SettingsScreenState createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   String selectedOption = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: Text('Settings Screen'),
//       // ),
//       body: ListView(
//         children: <Widget>[
//           ListTile(
//             title: Text('Profile'),
//             onTap: () {
//               setState(() {
//                 selectedOption = 'Profile';
//               });
//             },
//           ),
//           ListTile(
//             title: Text('Device Settings'),
//             onTap: () {
//               setState(() {
//                 selectedOption = 'Device Settings';
//               });
//             },
//           ),
//           ListTile(
//             title: Text('Help & Support'),
//             onTap: () {
//               setState(() {
//                 selectedOption = 'Help & Support';
//               });
//             },
//           ),
//           ListTile(
//             title: Text('Refer and Win'),
//             onTap: () {
//               setState(() {
//                 selectedOption = 'Refer and Win';
//               });
//             },
//           ),
//         ],
//       ),
//       bottomSheet: selectedOption.isNotEmpty
//           ? Container(
//               color: Colors.grey[200],
//               child: Center(
//                 child: Text(
//                   'Selected Option: $selectedOption',
//                   style: TextStyle(fontSize: 18),
//                 ),
//               ),
//             )
//           : null,
//     );
//   }
// }
