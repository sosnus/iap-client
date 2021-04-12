import 'package:fleetmanager/views/user_list.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'services/fleet_service.dart';

void setupLocator() {
  GetIt.I.registerLazySingleton(() => FleetService());
}

void main() {
  setupLocator();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserList(),
    );
  }
}
