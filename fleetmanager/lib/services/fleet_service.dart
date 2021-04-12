import 'dart:convert';

import 'package:fleetmanager/models/user.dart';
import 'package:http/http.dart' as http;
// import 'package:./models/api_response.dart';
import 'package:fleetmanager/models/api_response.dart';

class FleetService {
  static const addr = 'http://s-vm.northeurope.cloudapp.azure.com:8081';

  Future<APIResponse<List<User>>> getUserList() {
    return http.get(addr + '/users').then((data) {
      if (data.statusCode == 200) {
        final jsonData = json.decode(data.body);
        final notes = <User>[];
        for (var item in jsonData) {
          final note = User(
            id: item['id'],
            pesel: item['pesel'],
            firstName: item['firstName'],
            sureName: item['sureName'],
          );
          notes.add(note);
        }
        return APIResponse<List<User>>(data: notes);
      }
      return APIResponse<List<User>>(
          error: true, errorMessage: 'An error occured');
    }).catchError((_) =>
        APIResponse<List<User>>(error: true, errorMessage: 'An error occured'));
  }
}
