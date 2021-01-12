import 'package:flutter/widgets.dart';

abstract class BeamLocation {
  BeamLocation();
  BeamLocation.withParameters({
    this.pathParameters,
    this.queryParameters,
  });
  BeamLocation.without({int pageId});

  Map<String, String> queryParameters = {};
  Map<String, String> pathParameters = {};
  String _path;
  String _query;

  String get uri => this._path + this._query;
  String get path => this._path;

  void prepare() {
    this._makePath();
    this._makeQuery();
    this.executeBefore.call();
  }

  void _makeQuery() {
    if (this.queryParameters.length == 0) {
      this._query = '';
    }
    String result = '?';
    this.queryParameters.forEach((key, value) {
      result += key + '=' + value + '&';
    });
    this._query = result.substring(0, result.length - 1);
  }

  void _makePath() {
    List<String> pathSegments = Uri.parse(this.pathBlueprint).pathSegments;
    pathSegments = List.from(pathSegments);
    if (this.pathParameters.length == 0) {
      pathSegments.removeWhere((segment) => segment[0] == ':');
      this._path = '/' + pathSegments.join('/');
    }
    pathParameters.forEach((key, value) {
      int index = pathSegments.indexWhere(
          (segment) => segment[0] == ':' && segment.substring(1) == key);
      if (index != -1) {
        pathSegments[index] = value;
      }
    });
    this._path = '/' + pathSegments.join('/');
  }

  String get pathBlueprint;
  List<Page> get pages;
  BeamLocation get popLocation => null;
  bool get popToPrevious => false;
  void Function() executeBefore = () => {};
}
