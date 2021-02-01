import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hartslag/enum/data_request_type.dart';
import 'package:hartslag/services/data_request.dart';
import 'package:hartslag/services/store_data.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreenGe extends StatefulWidget {
  @override
  _CameraScreenGeState createState() => _CameraScreenGeState();
}

class _CameraScreenGeState extends State<CameraScreenGe> {
  List<CameraDescription> _cameras; // Liste der verfügbaren Kameras
  CameraController _controller; // Kamera-Steuerung
  int _cameraIndex; // Index der aktuellen Kamera
  bool _isRecording = false; // Flagge für laufende Aufzeichnung
  bool _videoCreated = false; // Flagge ob ein Video erstellt wurde
  String _filePath; //  Pfad der aufgezeichneten Datei
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    //  Überprüft beim Starten des Widgets die Liste der verfügbaren Kameras
    availableCameras().then((cameras) {
      // Speichern der Kameraliste
      _cameras = cameras;
      // Initialisieren Sie die Kamera nur, wenn in der Kameraliste Kameras verfügbar sind
      if (_cameras.length != 0) {
        // Initialisieren Sie den aktuellen Kamera-Index auf 0, um den ersten
        _cameraIndex = 0;
        // Initialisieren Sie die Kamera, indem Sie die Kamerabeschreibung der ausgewählten Kamera übergeben
        _initCamera(_cameras[_cameraIndex]);
      }
    });
  }

  // Initialisieren der Kamera
  _initCamera(CameraDescription camera) async {
    // Wenn der Controller verwendet wird,
    // eine Vorkehrung treffen, um sie zu stoppen, bevor sie weitermachen
    if (_controller != null) await _controller.dispose();
    // Geben Sie dem Controller die neue Kamera an, die verwendet werden soll
    _controller = CameraController(camera, ResolutionPreset.medium, enableAudio: false);
    //Fügen Sie einen Listener hinzu, um den Bildschirm bei jeder Änderung zu aktualisieren
    _controller.addListener(() => this.setState(() {}));
    // Initialisieren Sie den Controller
    _controller.initialize();
  }

  // Widget mit der Kameraanzeige erstellen
  Widget _buildCamera() {
    // Wenn der Controller null oder noch nicht initialisiert ist,
    // dem Benutzer eine Meldung anzeigen und die Anzeige einer nicht hochgefahrenen Kamera vermeiden
    if (_controller == null || !_controller.value.isInitialized) return Center(child: Text('Loading...'));
    //  Verwenden Sie ein AspectRatio-Widget, um die richtige Höhe und Breite anzuzeigen
    return AspectRatio(
      // Fordern Sie das Verhältnis Hoch/Breite vom Controller an
      aspectRatio: _controller.value.aspectRatio,
      // Anzeige von Treiber-Inhalten mit dem CameraPreview-Widget
      child: CameraPreview(_controller),
    );
  }

  // Erstellen Steuerelemente für Video
  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        // Icon zum Wechseln der Kamera
        IconButton(
          icon: Icon(Icons.flip_camera_ios, size: 35),
          onPressed: _onSwitchCamera,
        ),
        // Symbol zum Starten der Aufzeichnung
        IconButton(
          icon: Icon(Icons.radio_button_checked, size: 35),
          onPressed: _isRecording ? null : _onRecord,
        ),
        //Symbol zum Stoppen der Aufzeichnung
        IconButton(
          icon: Icon(Icons.stop, size: 35),
          onPressed: _isRecording ? _onStop : null,
        ),
        // Symbol zum Uploaden des Videos
        IconButton(
          icon: Icon(Icons.cloud_upload, size: 35),
          onPressed: _isRecording || !_videoCreated ? null : _onUpload,
        ),
      ],
    );
  }

  Widget _buildInfoText() {
    return new Container(
        margin: const EdgeInsets.only(top: 20, left: 5, right: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
                child: new Text(
              "Platzieren Sie Ihr Gesicht im dafür vorgesehenen Bereich & starten Sie die Aufnahme.",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ))
          ],
        ));
  }

  // Öffnen der zuletzt aufgezeichneten Videodatei
  // https://flutter.dev/docs/cookbook/design/snackbars
  // https://stackoverflow.com/questions/40579879/display-snackbar-in-flutter
  void _onUpload() async {
    try {
      var response = await DataRequest.uploadVideo(DataRequestType.face, this._filePath);
      if (response.statusCode == 201) {
        Map body = json.decode(response.body);
        if ((await StoreData.save('faceId', body['id']))) {
          this._scaffoldKey.currentState.showSnackBar(new SnackBar(
                content: Text('Das Video wurde erfolgreich hochgeladen.'),
                duration: Duration(seconds: 7),
              ));
          return;
        }
      }

      // ELSE
      this._scaffoldKey.currentState.showSnackBar(new SnackBar(
            content: Text('Das Video konnte nicht hochgeladen werden.'),
            action: SnackBarAction(
              label: 'Wiederholen',
              onPressed: () {
                this._onUpload();
              },
            ),
            duration: Duration(seconds: 7),
          ));
    } catch (_) {
      this._scaffoldKey.currentState.showSnackBar(new SnackBar(
            content: Text('Das Video kann nicht hochgeladen werden.'),
            duration: Duration(seconds: 7),
          ));
    }
  }

  // Videoaufzeichnung stoppen
  Future<void> _onStop() async {
    // Verwendung des Treibers zum Stoppen der Aufzeichnung
    await _controller.stopVideoRecording();
    // Aktualisieren Sie die Aufnahmeflagge
    setState(() {
      _isRecording = false;
      _videoCreated = true;
    });
  }

  // Videoaufzeichnung starten
  Future<void> _onRecord() async {
    // Holen Sie sich die vorläufige Adresse
    var directory = await getTemporaryDirectory();
    // Hinzufügen des Dateinamens zur temporären Adresse
    _filePath = directory.path + '/${DateTime.now()}.mp4';
    // Verwenden Sie den Treiber, um die Aufzeichnung zu starten
    _controller.startVideoRecording(_filePath);
    // Aktualisieren Sie die Aufnahmeflagge
    setState(() => _isRecording = true);
  }

  // Ändern der aktuellen Kamera
  void _onSwitchCamera() {
    // Wenn die Anzahl der Kameras 1 oder weniger beträgt,
    // den Wechsel nicht vornehmen
    if (_cameras.length < 2) return;
    // Änderung 1 in 0 oder 0 in 1
    _cameraIndex = (_cameraIndex + 1) % 2;
    // Initialisieren Sie die Kamera, indem Sie die Kamerabeschreibung der ausgewählten Kamera übergeben
    _initCamera(_cameras[_cameraIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Videoaufnahme Gesicht')),
      key: this._scaffoldKey,
      body: Column(children: [
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              height: 500,
              child: Center(
                child: _buildCamera(),
              ),
            ),
            Positioned(
              top: 50,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.red,
                    width: 4,
                  ),
                ),
                height: 400,
                width: 300,
              ),
            ),
          ],
        ),
        _buildControls(),
        _buildInfoText(),
      ]),
    );
  }
}
