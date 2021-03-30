import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'IAP App';

    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: Text(appTitle),
        ),
        body: MyCustomForm(),
      ),
    );
  }
}

// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  final controllerAddr = TextEditingController();

  final controllerEndpoint = TextEditingController();
  // final controllerAddrAndEndpoint = TextEditingController();
  final controllerOutput = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    controllerAddr.dispose();
    controllerEndpoint.dispose();
    super.dispose();
  }

  Future<String> fetchAlbum() async {
    final response =
        await http.get(Uri.https('jsonplaceholder.typicode.com', 'albums/1'));
    // await http.get(Uri.https('jsonplaceholder.typicode.com', 'albums/1'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print(response.body);
      controllerOutput.text = response.body;
      return response.body;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: controllerAddr,
            decoration: const InputDecoration(
              icon: Icon(Icons.vpn_lock),
              hintText: 'Enter backend address here',
              labelText: 'Backend address',
            ),
            // initialValue: "http://s-vm.northeurope.cloudapp.azure.com:5000",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          TextFormField(
            controller: controllerEndpoint,
            decoration: const InputDecoration(
              icon: Icon(Icons.api),
              hintText: 'Write endpoint addr here, add / at begenning',
              labelText: 'Endpoint',
            ),
            // initialValue: "/hello",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                fetchAlbum();
                controllerOutput.text = controllerAddr.text;
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Processing Data for ${controllerAddr.text}${controllerEndpoint.text}')));
                }
              },
              child: Text('Submit'),
            ),
          ),
          TextField(
            // enabled: false,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: controllerOutput,
            decoration: const InputDecoration(
              hintText: 'Respond from server',
              labelText: 'Output',
            ),
            // initialValue: "/hello",
          ),
        ],
      ),
    );
  }
}
