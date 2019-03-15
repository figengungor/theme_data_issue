import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  BehaviorSubject<String> dataController = BehaviorSubject<String>();

  Future<void> _fetchData() async {
    String data = await Future.delayed(Duration(seconds: 3), () => "Data");
    dataController.add(data);
  }

  Future<void> _restart() async {
    dataController.add(null);
    _fetchData();
  }

  final key = GlobalKey();

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: dataController.stream,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        final Widget app = MaterialApp(
          key: key,
          title: 'Flutter Demo',
          theme: snapshot.hasData
              ? ThemeData(
                  primaryColor: Colors.pink,
                  textTheme: Theme.of(context).textTheme.copyWith(
                        headline: Theme.of(context)
                            .textTheme
                            .headline
                            .copyWith(color: Colors.white),
                      ),
                )
              : ThemeData(
                  primarySwatch: Colors.red,
                ),
          home: snapshot.hasData
              ? MyHomePage(
                  restart: _restart,
                )
              : SplashPage(dataStream: dataController.stream),
        );

        if (snapshot.hasData) {
          return DataProvider(
            data: snapshot.data,
            child: app,
          );
        } else {
          return app;
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final VoidCallback restart;

  const MyHomePage({Key key, this.restart}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Container(
        child: FlatButton(onPressed: widget.restart, child: Text('Restart')),
      ),
    );
  }
}

class SplashPage extends StatelessWidget {
  final Stream<String> dataStream;

  const SplashPage({Key key, this.dataStream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: StreamBuilder(
          stream: dataStream,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) =>
              snapshot.hasError
                  ? Container(
                      color: Colors.red,
                    )
                  : Center(child: CircularProgressIndicator())),
    );
  }
}

class DataProvider extends StatelessWidget {
  final String data;

  final Widget child;

  const DataProvider({@required this.child, this.data});

  static DataProvider of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedDataProvider)
            as _InheritedDataProvider)
        .data;
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedDataProvider(data: this, child: child);
  }
}

class _InheritedDataProvider extends InheritedWidget {
  final DataProvider data;

  const _InheritedDataProvider(
      {Key key, @required this.data, @required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}
