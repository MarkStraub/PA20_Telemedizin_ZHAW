/// An enum which contains the correct suffix for the api of the requested type
///
/// https://dart.dev/guides/language/extension-methods
enum DataRequestType { face, root, wrist }

extension ParseToString on DataRequestType {
  /// Return the suffix as a String of [DataRequestType]
  String urlSuffix() {
    switch (this) {
      case DataRequestType.face:
        return 'face';
      case DataRequestType.wrist:
        return 'wrist';
      default:
        throw ('DATA REQUEST TYPE not defined: $this');
    }
  }
}
