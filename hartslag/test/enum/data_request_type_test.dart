import 'package:flutter_test/flutter_test.dart';
import 'package:hartslag/enum/data_request_type.dart';

void main() {
  group('URL Suffix', () {
    test('Suffix as String', () {
      expect(DataRequestType.face.urlSuffix(), 'face', reason: 'Suffix of video should be "face"');
      expect(DataRequestType.wrist.urlSuffix(), 'wrist', reason: 'Suffix of video should be "wrist"');
    });
  });
}
