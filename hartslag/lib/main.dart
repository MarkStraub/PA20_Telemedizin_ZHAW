import 'package:flutter/material.dart';
import 'package:hartslag/screens/camera_screen_ge.dart';
import 'package:hartslag/screens/result_screen.dart';
import 'package:hartslag/services/store_data.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hartslag',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Hartslag'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(fit: FlexFit.tight, flex: 1, child: Container()),
            Flexible(fit: FlexFit.tight, flex: 3, child: Container(child: Center(child: _fullLogo()))),
            Flexible(fit: FlexFit.tight, flex: 1, child: Container(child: _buildTextFields())),
            Flexible(fit: FlexFit.tight, flex: 2, child: Container(child: _buildButtons())),
            Flexible(fit: FlexFit.tight, flex: 1, child: Container()),
          ],
        ),
      ),
    );
  }

  Future navigateToGe(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CameraScreenGe()));
  }

  // Future navigateToHg(context) async {
  //   Navigator.push(
  //       context, MaterialPageRoute(builder: (context) => CameraScreenHg()));
  // }

  Future navigateToResult(context) async {
    String faceId;
    // Check if the faceId is to old to present
    // Older than 2 hours
    if ((faceId = await StoreData.read('faceId')) != null && (await StoreData.read('dateFace')) != null) {
      var dateFace = DateTime.parse(await StoreData.read('dateFace'));
      if (DateTime.now().subtract(Duration(hours: 2)).compareTo(dateFace) == 1) {
        // Video is older than 2 hours. Delete the data
        StoreData.delete('faceId');
        StoreData.delete('dataFace');
      }
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          videoId: faceId,
        ),
      ),
    );
  }

  Widget _fullLogo() {
    return new Container(
      child: Image(
        image: AssetImage('assets/images/cardiogram.png'),
        //color: color,
      ),
    );
  }

  Widget _buildTextFields() {
    return new Container(
        margin: const EdgeInsets.only(top: 40, left: 5, right: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
                child: new Text(
              "Wählen Sie eine Methode zur Pulsmessung:",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ))
          ],
        ));
  }

  Widget _buildButtons() {
    return new Container(
      margin: const EdgeInsets.only(top: 40, left: 5, right: 5),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: double.maxFinite,
            height: 50,
            child: Opacity(
              opacity: 0.6,
              child: RaisedButton.icon(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                textColor: Colors.white,
                color: Colors.blue,
                onPressed: () {
                  navigateToGe(context);
                },
                icon: Icon(Icons.face, size: 25),
                label: Text('GESICHT', style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal)),
              ),
            ),
          ),
          // Not implemented yet
          // SizedBox(height: 30),
          // SizedBox(
          //   width: double.maxFinite,
          //   height: 50,
          //   child: Opacity(
          //     opacity: 0.6,
          //     child: RaisedButton.icon(
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(18.0),
          //       ),
          //       textColor: Colors.white,
          //       color: Colors.blue,
          //       onPressed: () {
          //         navigateToHg(context);
          //       },
          //       icon: Icon(Icons.pan_tool, size: 25),
          //       label: Text('HANDGELENK',
          //           style:
          //               TextStyle(fontSize: 20, fontWeight: FontWeight.normal)),
          //     ),
          //   ),
          // ),
          SizedBox(height: 30),
          SizedBox(
            width: double.maxFinite,
            height: 50,
            child: Opacity(
              opacity: 0.6,
              child: RaisedButton.icon(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                textColor: Colors.white,
                color: Colors.blue,
                onPressed: () {
                  navigateToResult(context);
                },
                icon: Icon(Icons.star, size: 25),
                label: Text('RESULTAT', style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
