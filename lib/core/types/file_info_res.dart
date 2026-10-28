import 'dart:convert';

class FileInfoRes {
  final String _source;

  const new(this._source);

  String get text => _source;
  Map<String, dynamic> get toMap => jsonDecode(_source);
}
