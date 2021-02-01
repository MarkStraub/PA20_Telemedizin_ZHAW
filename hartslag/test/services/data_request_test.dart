import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hartslag/enum/data_request_type.dart';
import 'package:hartslag/services/data_request.dart';

/// In data_request.dart you may need to change the url
String _faceId = 'test';

void main() {
  group('Upload video Requests', () {
    test('face', () async {
      var filePath = 'test_resources/baby.mp4';

      var response = await DataRequest.uploadVideo(DataRequestType.face, filePath);
      expect(response.statusCode, 201, reason: 'Status should be 201 (Created)');
      expect(response.reasonPhrase, 'Created', reason: 'Status should be Created (201)');

      Map body = json.decode(response.body);
      expect(body.containsKey('id'), true, reason: "Body should contains key 'id'");
      expect(body['id']?.length, 36, reason: "The 'id' should have 36 characters");

      expect(body.containsKey('time'), true, reason: "Body should contains key 'id'");

      expect(body.containsKey('success'), true, reason: "Body should contains key 'success'");
      expect(body['success'], true, reason: "Body should contains key 'success'");

      // Update face id
      _faceId = body['id'];
    });
  });

  group('Get Heart Rate Requests', () {
    test('face', () async {
      var response = await DataRequest.getHeartRate(DataRequestType.face, _faceId);
      expect(response.statusCode, 200, reason: 'Status should be 200 (OK)');
      expect(response.reasonPhrase, 'OK', reason: 'Status should be OK (200)');

      Map body = json.decode(response.body);
      expect(body.containsKey('faceId'), true, reason: "Body should contains key 'faceId'");
      expect(body['faceId'], _faceId, reason: "The 'faceId' should be the same as requested");

      expect(body.containsKey('heartRate'), true, reason: "Body should contains key 'heartRate'");
      expect(body['heartRate'].compareTo(40), isNot(-1), reason: "Heart rate should be at least 40");
      expect(body['heartRate'].compareTo(220), isNot(1), reason: "Heart rate should be not higher than 220");
    });
  });
}
