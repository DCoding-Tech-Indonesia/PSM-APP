import 'dart:io';

class DocumentReturnValue {
  final File file;
  final int id;
  final String url;

  DocumentReturnValue({
    required this.file,
    required this.id,
    required this.url,
  });
}