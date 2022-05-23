import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';



class bleConnections {
  Firestore _firestore = Firestore.instance;
  final Strategy strategy = Strategy.P2P_STAR;


  void getPermissions() async{

    if(await Permission.location.serviceStatus.isEnabled) {
        print("location is enabled");
        //Nearby().enableLocationServices();
    } else {
      var locStatus = await Permission.location.status;
      if(locStatus.isGranted) {
        print("location is granted and enabled");
      } else if (locStatus.isDenied) {
        Map<Permission,PermissionStatus> locstatus = await [
          Permission.location,
        ].request();

       // Nearby().enableLocationServices();
      }
    }


    if (await Nearby().checkBluetoothPermission()) {
      print("ble enabled");
    } else {
      Nearby().askBluetoothPermission();
    }

  }

  void discovery(String emailid) async {
    try {
      bool a = await Nearby().startDiscovery(emailid, strategy,
          onEndpointFound: (id, name, serviceId) async {
            print('I saw id:$id with name:$name'); // the name here is an email

          }, onEndpointLost: (id) {
            print(id);
          });
      print('DISCOVERING: ${a.toString()}');
    } catch (e) {
      print(e);
    }
  }


  void advertisement(String emailid) async {
    try{

      bool a = await Nearby().startAdvertising(
        emailid,
        strategy,
        onConnectionInitiated: null,
        onConnectionResult: (id, status) {
          print(status);
        },
        onDisconnected: (id) {
          print('Disconnected $id');
        },
      );

    } catch(e) {
      print(e);
    }
  }
}
