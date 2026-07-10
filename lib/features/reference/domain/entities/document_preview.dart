import 'package:equatable/equatable.dart';

class DocumentPreview extends Equatable {
  final int idDocument;
  final String url;

  const DocumentPreview({required this.idDocument, required this.url});

  factory DocumentPreview.fromJson(Map<String, dynamic> json) {
    return DocumentPreview(
      idDocument: json['idDocument'] ?? 0,
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {"idDocument": idDocument, "url": url};

  @override
  List<Object?> get props => [idDocument, url];
}
