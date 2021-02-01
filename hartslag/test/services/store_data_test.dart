import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hartslag/services/store_data.dart';

Future<void> main() async {
  // Init for tests
  TestWidgetsFlutterBinding.ensureInitialized();

// Test data
  final String faceId = 'eiske38s-38s3-siq2-isef-s931-iakels3kfeis';
  final DateTime dateTime = DateTime.now();
  final String dateTimeString = dateTime.toString();

  setUpAll(() {
    const MethodChannel('plugins.flutter.io/shared_preferences').setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{};
      }
      return null;
    });
  });

  group('Save data', () {
    test('Face data', () async {
      expect(await StoreData.save('faceId', faceId), true, reason: 'Could not save the data faceId');
      expect(await StoreData.save('dateFace', dateTimeString), true, reason: 'Could not save the data dateFace');
    });
  });

  group('Read data', () {
    test('Face data', () async {
      expect(await StoreData.read('faceId'), faceId, reason: 'Could not read the data faceId');

      var readDateFace = DateTime.parse((await StoreData.read('dateFace')));
      expect(readDateFace, dateTime, reason: 'Could not read the data dateTime');
    });
  });

  group('Compare data', () {
    test('DateTime data', () async {
      var futureDateTime = dateTime.add(Duration(hours: 2));

      var dateFace = DateTime.parse((await StoreData.read('dateFace')));

      expect(futureDateTime.subtract(Duration(hours: 2)).compareTo(dateFace), 0, reason: 'DateTime should be the same');
      expect(futureDateTime.subtract(Duration(hours: 2)).add(Duration(seconds: 1)).compareTo(dateFace), 1, reason: 'Stored DateTime should be older');
      expect(futureDateTime.subtract(Duration(hours: 2, seconds: 1)).compareTo(dateFace), -1, reason: 'Stored DateTime should be newer');
    });
  });

  group('Update data', () {
    test('Face data', () async {
      final String newFaceId = "eiske38s-38s3-siq2-isef-s931-000000000000";

      // Save
      expect(await StoreData.update('faceId', newFaceId), true, reason: 'Could not update the data faceId');

      // Read
      expect(await StoreData.read('faceId'), isNot(faceId), reason: 'Could not updated data faceId');
      expect(await StoreData.read('faceId'), newFaceId, reason: 'Could not read the updated data faceId');
    });
  });

  group('Delete data', () {
    test('Face data', () async {
      // Delete
      expect(await StoreData.delete('faceId'), true, reason: 'Could not delete data faceId');
      expect(await StoreData.delete('dateFace'), true, reason: 'Could not delete data dateFace');

      // Read
      expect(await StoreData.read('faceId'), null, reason: 'Deleted data is not null faceId');
      expect(await StoreData.read('dateFace'), null, reason: 'Deleted data is not null dateFace');
    });
  });
}
