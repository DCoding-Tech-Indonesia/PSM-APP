import 'package:equatable/equatable.dart';

class KmbusDocument extends Equatable {
  final int? idDetailDocument;
  final int idDocument;
  final int idDocumentType;
  final String? urlDoc;

  const KmbusDocument({
    this.idDetailDocument,
    required this.idDocument,
    required this.idDocumentType,
    this.urlDoc,
  });

  KmbusDocument copyWith({
    int? idDetailDocument,
    int? idDocument,
    int? idDocumentType,
    String? urlDoc,
  }) {
    return KmbusDocument(
      idDetailDocument: idDetailDocument ?? this.idDetailDocument,
      idDocument: idDocument ?? this.idDocument,
      idDocumentType: idDocumentType ?? this.idDocumentType,
      urlDoc: urlDoc ?? this.urlDoc,
    );
  }

  factory KmbusDocument.fromJson(Map<String, dynamic> json) {
    return KmbusDocument(
      idDetailDocument: json['id_detail_document'] ?? json['idDetailDocument'],
      idDocument: json['id_document'] ?? json['idDocument'] ?? 0,
      idDocumentType: json['id_document_type'] ?? json['idDocumentType'] ?? 0,
      urlDoc: json['url_doc'] ?? json['urlDoc'],
    );
  }

  factory KmbusDocument.fromMap(Map<String, dynamic> map) => KmbusDocument.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      'id_detail_document': idDetailDocument,
      'id_document': idDocument,
      'id_document_type': idDocumentType,
      'url_doc': urlDoc,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  @override
  List<Object?> get props => [idDetailDocument, idDocument, idDocumentType, urlDoc];
}