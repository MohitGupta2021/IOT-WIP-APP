// // // /*
// // //  * Package : mqtt_client
// // //  * Author : S. Hamblett <steve.hamblett@linux.com>
// // //  * Date   : 10/07/2021
// // //  * Copyright :  S.Hamblett
// // //  *
// // //  */

// // // import 'dart:async';
// // // import 'dart:io';
// // // import 'package:mqtt_client/mqtt_server_client.dart';
// // // import 'package:mqtt_client/mqtt_client.dart';

// // // Future<void> main() async {
// // //   const url = 'a1hjtipwb9wtw6-ats.iot.ap-south-1.amazonaws.com';
// // //   const port = 8883;
// // //   const clientId = '12';

// // //   final client = MqttServerClient.withPort(url, clientId, port);

// // //   client.secure = true;
// // //   client.keepAlivePeriod = 20;
// // //   client.setProtocolV311();
// // //   client.logging(on: false);

// // //   // Remove Flutter-specific code related to loading assets
// // //   // ByteData rootCA = await rootBundle.load('assets/certs/AmazonRootCA1.pem');
// // //   // ByteData deviceCert = await rootBundle.load('assets/certs/c23b9b1b7672c7d4e66148b84febeed1098f9884a6218a84de230b3855187daa-certificate.pem.crt');
// // //   // ByteData privateKey = await rootBundle.load('assets/certs/c23b9b1b7672c7d4e66148b84febeed1098f9884a6218a84de230b3855187daa-private.pem.key');

// // //   // Load certificates from local paths (modify these paths according to your setup)
// // //   final rootCA = File('assets/cert/AmazonRootCA1.pem');
// // //   final deviceCert = File('assets/cert/c23b9b1b7672c7d4e66148b84febeed1098f9884a6218a84de230b3855187daa-certificate.pem.crt');
// // //   final privateKey = File('assets/cert/c23b9b1b7672c7d4e66148b84febeed1098f9884a6218a84de230b3855187daa-private.pem.key');

// // //   SecurityContext context = SecurityContext.defaultContext;
// // //   context.setClientAuthoritiesBytes(await rootCA.readAsBytes());
// // //   context.useCertificateChainBytes(await deviceCert.readAsBytes());
// // //   context.usePrivateKeyBytes(await privateKey.readAsBytes());

// // //   client.securityContext = context;

// // //   final connMess = MqttConnectMessage()
// // //       .withClientIdentifier(clientId)
// // //       .startClean();
// // //   client.connectionMessage = connMess;

// // //   try {
// // //     print('MQTT client connecting to AWS IoT using certificates....');
// // //     await client.connect();
// // //   } on Exception catch (e) {
// // //     print('MQTT client exception - $e');
// // //     client.disconnect();
// // //     exit(-1);
// // //   }

// // //   if (client.connectionStatus!.state == MqttConnectionState.connected) {
// // //     print('MQTT client connected to AWS IoT');

// // //     await MqttUtilities.asyncSleep(1);
// // //     const topic = '/test/topic';
// // //     final builder = MqttClientPayloadBuilder();
// // //     builder.addString('Hello World');
// // //     client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);

// // //     client.subscribe(topic, MqttQos.atLeastOnce);

// // //     client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
// // //       final recMess = c[0].payload as MqttPublishMessage;
// // //       final pt =
// // //           MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
// // //       print(
// // //           'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
// // //       print('');
// // //     });
// // //   } else {
// // //     print(
// // //         'ERROR MQTT client connection failed - disconnecting, state is ${client.connectionStatus!.state}');
// // //     client.disconnect();
// // //   }

// // //   print('Sleeping....');
// // //   await MqttUtilities.asyncSleep(10);

// // //   print('Disconnecting');
// // //   client.disconnect();
// // // }


import 'dart:async';
import 'dart:convert'; // Add this import for JSON parsing
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:percent_indicator/circular_percent_indicator.dart'; // Add this import

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autoswitch Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController messageController = TextEditingController();
  late MqttServerClient client;
  String receivedMessage = '';
  String subscribeData = '';

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
    int waterLevel = 0; // Initialize water level

    try {
      waterLevel = json.decode(subscribeData)['waterlevel'];
    } catch (e) {
      // Handle JSON parsing error
      print(e);
    }
    return Scaffold(
  appBar: AppBar(
    title: Text('IOT APP'),
    backgroundColor: Colors.teal,
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
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(color: Colors.blue, width: 10.0),
            ),
            child: Center(
              child: Text(
                '$waterLevel%',
                style: TextStyle(fontSize: 24, color: Colors.blue),
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: 250,
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: 'Message to Publish',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              publishMessage();
              messageController.clear();
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.teal,
            ),
            child: Text(
              'Publish Message',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          SizedBox(height: 130), // Add space at the bottom to prevent overflow
        ],
      ),
    ),
  ),
);

  }
}

//main.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

// class QRScreen extends StatefulWidget {
//   const QRScreen({Key? key}) : super(key: key);

//   @override
//   State<QRScreen> createState() => _QRScreenState();
// }

// class _QRScreenState extends State<QRScreen> {
//   String? _scanCode;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("QR Code"),
//         centerTitle: true,
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _scanCode == null
//               ? SizedBox()
//               : Text(
//                   "Scanned Code -  $_scanCode",
//                   style: TextStyle(
//                     color: Colors.blue,
//                     fontSize: 18,
//                   ),
//                 ),
//           SizedBox(height: 20,),
//           TextButton(
//             onPressed: () {
//               scanQR();
//             },
//             child: Text("Scan Code"),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> scanQR() async {
//     String barcodeScanRes;
//     try {
//       barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
//         '#ff6666',
//         'Cancel',
//         true,
//         ScanMode.QR,
//       );
//     } on PlatformException {
//       barcodeScanRes = 'Failed to get platform version.';
//     }
//     if (!mounted) return;

//     setState(() {
//       _scanCode = barcodeScanRes;
//     });
//   }
// }

