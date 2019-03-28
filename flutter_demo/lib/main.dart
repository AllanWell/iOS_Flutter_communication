import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:flutter/services.dart';

void main() => runApp(MyApp(routeParam: window.defaultRouteName,));

class MyApp extends StatelessWidget {
  final String routeParam;

  const MyApp({Key key, this.routeParam}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iOS Flutter Communication',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'iOS Flutter Communication', routeParam: routeParam,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.routeParam}) : super(key: key);

  final String title;
  final String routeParam;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  static const BasicMessageChannel<String> _basicMessageChannel_flutter2iOS = BasicMessageChannel('BasicMessageChannel_flutter2iOS', StringCodec());
  static const BasicMessageChannel<String> _basicMessageChannel_iOS2flutter = BasicMessageChannel('BasicMessageChannel_iOS2flutter', StringCodec());
  static const MethodChannel _methodChannel = MethodChannel('MethodChannel');
  static const EventChannel _eventChannel = EventChannel('EventChannel');

  StreamSubscription _streamSubscription;

  String showMessage = '';

  String _basicMessageChannelReceive = '';
  String _basicMessageChannelSendInput = '';
  String _basicMessageChannelSendReply = '';

  String _eventChannelReceive = "";

  bool _methodChannelDoneFlag = true;
  String _methodChannelReceive = "";

  @override
  void initState() {
    super.initState();
    // BasicMessageChannel 接受 iOS 的消息，并回复
    _basicMessageChannel_iOS2flutter.setMessageHandler((String message) => Future<String>(() {
      setState(() {
        _basicMessageChannelReceive = message;
      });
      return  message + '<-flutter';
    }));

    // EventChannel 
    _streamSubscription = _eventChannel.receiveBroadcastStream('123')
      .listen(_eventListen, onError: _eventListenError);

    _methodChannel.setMethodCallHandler((call) => Future<dynamic>(() {
      setState(() {
        _methodChannelReceive = call.toString();
      });
    }));

  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  void _eventListen(message) {
    setState(() {
      _eventChannelReceive = message;
    });
  }

  void _eventListenError(error) {
    print(error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: Colors.lightBlueAccent),
        alignment: Alignment.topLeft,
        child: Column(
          children: <Widget>[
            _route_reveive,
            _basicMessageChannel_receive,
            _basicMessageChannel_send,
            _eventChannel_receive,
            _methodChannel_receive,
            _methodChannel_send,
          ],
        ),
      )
    );
  }

  Widget get _route_reveive {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.fromLTRB(15, 5, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('RouteParam Receive', style: TextStyle(color: Colors.pinkAccent, fontSize: 16)),
          Text(widget.routeParam)
        ],
      ),
    );
  }

  Widget get _basicMessageChannel_receive {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.fromLTRB(15, 5, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('BasicMessageChannel Receive', style: TextStyle(color: Colors.pinkAccent, fontSize: 16)),
          Text(_basicMessageChannelReceive)
        ],
      ),
    );
  }

  Widget get _basicMessageChannel_send {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.fromLTRB(15, 5, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('BasicMessageChannel Send', style: TextStyle(color: Colors.pinkAccent, fontSize: 16)),
          Row(
            children: <Widget>[
              Container(
                width: 200,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      this._basicMessageChannelSendInput = value;
                    });
                  },
                ),
              ),
              FlatButton(
                child: Text("Send"),
                onPressed: () {
                  _basicMessageChannel_flutter2iOS
                    .send(this._basicMessageChannelSendInput)
                    .then((messageReply) {
                      setState(() {
                        this._basicMessageChannelSendReply = messageReply;
                      });
                    })
                  ;
                },
              )
            ],
          ),
          Text(_basicMessageChannelSendReply)
        ],
      ),
    );
  }

  Widget get _eventChannel_receive {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.fromLTRB(15, 5, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('EventChannel Receive', style: TextStyle(color: Colors.pinkAccent, fontSize: 16)),
          Text(_eventChannelReceive)
        ],
      ),
    );
  }

  Widget get _methodChannel_send {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.fromLTRB(15, 5, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('MethodChannel', style: TextStyle(color: Colors.pinkAccent, fontSize: 16)),
          Row(
            children: <Widget>[
              FlatButton(
                child: Text("Send"),
                onPressed: () {
                  _methodChannel
                    .invokeMethod("iOS_method", "hello_iOS")
                    .then((value) {
                      if (value != null) {
                        setState(() {
                          _methodChannelDoneFlag = false;
                        });
                      }
                  });
                },
              ),
              Offstage(
                offstage: _methodChannelDoneFlag,
                child: Text("Done", style: TextStyle(color: Colors.green), ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget get _methodChannel_receive {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.fromLTRB(15, 5, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('MethodChannel Receive', style: TextStyle(color: Colors.pinkAccent, fontSize: 16)),
          Text(_methodChannelReceive)
        ],
      ),
    );
  }

}
