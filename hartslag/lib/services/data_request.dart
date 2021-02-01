import 'dart:async';

import 'package:hartslag/enum/data_request_type.dart';
import 'package:http/http.dart' as http;

class DataRequest {
  /// The url of the API
  /// https://developer.android.com/studio/run/emulator-networking
  // static const String _url = 'http://127.0.0.1:8000/';
  static const String _url = 'http://10.0.2.2:8000/';

  /// Gets an existing object
  ///
  /// Throws an [Error] if the parameter drt [DataRequestType] is not found.
  /// Returns the answer [Future<http.Response>] of the get request
  static Future<http.Response> getHeartRate(DataRequestType drt, String id) async {
    final url = '${_url + drt.urlSuffix()}/heartrate/$id';
    var uri = Uri.parse(url);

    return (await http.get(uri));
  }

  /// Upload a video with a post request
  ///
  /// Throws an [Error] if the parameter drt [DataRequestType] is not found.
  /// Returns the answer [Future<http.StreamedResponse>] of the get request
  static Future<http.Response> uploadVideo(DataRequestType drt, String filePath, {String filename}) async {
    // https://pub.dev/documentation/http/latest/http/MultipartRequest-class.html
    final url = _url + drt.urlSuffix();
    var uri = Uri.parse(url);

    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('datafile', filePath, filename: filename));

    var streamdResponse = await request.send();

    var response = http.Response.fromStream(streamdResponse);

    return response;
  }
}
