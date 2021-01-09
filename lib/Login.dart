import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
import 'Home.dart';

InputDecoration inputdecoration = InputDecoration(
  hintText: 'Enter your email',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  IO.Socket socket;

  Function join() {
    socket.emit('join', jsonEncode({'username': username, 'room': room}));
  }

  String username;
  String room;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('recreating socket');

    socket = IO.io(
        'http://192.168.1.50:8080',
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .setExtraHeaders({'foo': 'bar'})
            .disableAutoConnect() // optional
            .build());
    socket.connect();
    socket.onConnectError((data) => print('conect_error'));
    socket.onConnectTimeout((data) => print('timeout'));
    socket.onDisconnect((data) => print(data));
    socket.onReconnect((data) => print('recon'));
    socket.onConnect((_) {
      print('connected');
    });
    socket.on('joineresponce', (data) {
      if (data['error'] != null) {
        print('error');
        return;
      }
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => ChatScreen(
                socket: socket,
                username: username,
                room: room,
              )));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
              child: Hero(
                tag: 'hero',
                child: Container(
                  height: 200.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
            ),
            SizedBox(
              height: 48.0,
            ),
            TextField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  username = value;
                },
                decoration:
                    inputdecoration.copyWith(hintText: 'Enter your name')),
            SizedBox(
              height: 8.0,
            ),
            TextField(
              obscureText: true,
              textAlign: TextAlign.center,
              onChanged: (value) {
                room = value;
              },
              decoration: inputdecoration.copyWith(hintText: 'Enter room name'),
            ),
            SizedBox(
              height: 24.0,
            ),
            WelcomButton(
              text: 'Enter',
              color: Colors.blueAccent,
              onPressede: () {
                join();
              },
            )
          ],
        ),
      ),
    );
  }
}

class WelcomButton extends StatelessWidget {
  String text;
  Color color;
  Function onPressede;
  WelcomButton({this.text, this.onPressede, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: () {
            onPressede.call();
          },
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            text,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
