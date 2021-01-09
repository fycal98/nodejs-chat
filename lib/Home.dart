import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
import 'Login.dart';

class ChatScreen extends StatefulWidget {
  final socket;
  final username;
  final room;
  ChatScreen({this.socket, this.username, this.room});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

String username;

class _ChatScreenState extends State<ChatScreen> {
  IO.Socket socket;
  List<Map<String, dynamic>> messages = [];
  String sendedText;
  TextEditingController txtcontroller = TextEditingController();
  List<dynamic> users = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    socket = widget.socket;

    socket.on('newuser', (data) {
      setState(() {
        messages.add({'message': '$data connected', 'system': true});
      });
    });
    socket.on('userleft', (data) {
      setState(() {
        messages.add({'message': '$data has left', 'system': true});
      });
    });
    socket.on('receivemsg', (data) {
      messages.add({'message': data['msg'], 'sender': data['sender']});
      print(messages);
      setState(() {});
      // setState(() {});
    });
    socket.on('users', (data) {
      // users = data;

      setState(() {});
    });
    socket.on('unjoined', (data) {
      socket.dispose();
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.supervised_user_circle,
              size: 50,
            ),
            Text('online'),
            ...users.map((e) {
              if (e == widget.username) {
                return Container();
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e,
                      style: TextStyle(color: Colors.black87),
                    ),
                    Icon(
                      Icons.circle,
                      color: Colors.greenAccent,
                      size: 10,
                    )
                  ],
                ),
              );
            }).toList()
          ],
        ),
      ),
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                socket.emit('unjoin');
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: ListView(
                reverse: true,
                children: messages
                    .map((element) {
                      if (element['system'] != null) {
                        return Center(
                            child: Text(
                          element['message'],
                          style: TextStyle(color: Colors.black45),
                        ));
                      }

                      return MessageMat(
                        message: element['message'],
                        sender: element['sender'],
                        mymsg: element['sender'] == widget.username,
                      );
                    })
                    .toList()
                    .reversed
                    .toList(),
              ),
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: txtcontroller,
                      onChanged: (value) {
                        sendedText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      socket.emit(
                          'sendmsg',
                          jsonEncode({
                            'msg': txtcontroller.text,
                            'sender': widget.username,
                            'room': widget.room
                          }));
                      txtcontroller.clear();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageMat extends StatelessWidget {
  MessageMat({this.message, this.sender, this.mymsg});
  var message = '';
  var sender = '';
  bool mymsg;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            mymsg ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(sender, style: TextStyle(fontSize: 10.0, color: Colors.black54)),
          Material(
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                message,
                style: TextStyle(
                    color: mymsg ? Colors.white : Colors.black87,
                    fontSize: 20.0),
              ),
            ),
            borderRadius: mymsg
                ? BorderRadius.only(
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0),
                    topLeft: Radius.circular(15.0),
                  )
                : BorderRadius.only(
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                  ),
            color: mymsg ? Colors.lightBlue : Colors.white,
          ),
        ],
      ),
    );
  }
}

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
);
