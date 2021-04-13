import 'package:fleetmanager/models/api_response.dart';
import 'package:fleetmanager/models/user.dart';
import 'package:fleetmanager/views/user_remove.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:fleetmanager/services/fleet_service.dart';

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  FleetService get service => GetIt.I<FleetService>();

  APIResponse<List<User>> _apiResponse;
  bool _isLoading = false;

  @override
  void initState() {
    _fetchUsers();
    super.initState();
  }

  _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    _apiResponse = await service.getUserList();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('List of users')),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _fetchUsers();
            // Navigator.of(context)
            // .push(MaterialPageRoute(builder: (_) => NoteModify()));
          },
          child: Icon(Icons.add),
        ),
        body: Builder(
          builder: (_) {
            if (_isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (_apiResponse.error) {
              return Center(child: Text(_apiResponse.errorMessage));
            }

            return ListView.separated(
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.green),
              itemBuilder: (_, index) {
                return Dismissible(
                  key: ValueKey(_apiResponse.data[index].id),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (direction) {},
                  confirmDismiss: (direction) async {
                    final result = await showDialog(
                        context: context, builder: (_) => UserDelete());
                    print(result);
                    return result;
                  },
                  background: Container(
                    color: Colors.red,
                    padding: EdgeInsets.only(left: 16),
                    child: Align(
                      child: Icon(Icons.delete, color: Colors.white),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  child: ListTile(
                      title: Text(
                        _apiResponse.data[index].sureName,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      subtitle:
                          Text('PESEL: ${_apiResponse.data[index].pesel}'),
                      onTap: () {}
                      // Navigator.of(context).push(MaterialPageRoute(
                      // builder: (_) => UserModify(
                      // noteID: _apiResponse.data[index].id)));
                      // },
                      ),
                );
              },
              itemCount: _apiResponse.data.length,
            );
          },
        ));
  }
}
