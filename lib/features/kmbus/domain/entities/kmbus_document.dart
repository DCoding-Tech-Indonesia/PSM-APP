import 'package:equatable/equatable.dart';

class KmbusDocument extends Equatable {
  final int? idKmDocument;
  final int idDocument;
  final int idDocumentType;
  final String? urlDoc;

  const KmbusDocument({
    this.idKmDocument,
    required this.idDocument,
    required this.idDocumentType,
    this.urlDoc,
  });

  String? get url => urlDoc;

  KmbusDocument copyWith({
    int? idKmDocument,
    int? idDocument,
    int? idDocumentType,
    String? urlDoc,
  }) {
    return KmbusDocument(
      idKmDocument: idKmDocument ?? this.idKmDocument,
      idDocument: idDocument ?? this.idDocument,
      idDocumentType: idDocumentType ?? this.idDocumentType,
      urlDoc: urlDoc ?? this.urlDoc,
    );
  }

  factory KmbusDocument.fromJson(Map<String, dynamic> json) {
    return KmbusDocument(
      idKmDocument: json['id_detail_document'] ?? json['idKmDocument'],
      idDocument: json['id_document'] ?? json['idDocument'] ?? 0,
      idDocumentType: json['id_document_type'] ?? json['idDocumentType'] ?? 0,
      urlDoc: json['urlDoc'] ?? json['url_doc'],
    );
  }

  factory KmbusDocument.fromMap(Map<String, dynamic> map) => KmbusDocument.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      'idKmDocument': idKmDocument,
      'idDocument': idDocument,
      'idDocumentType': idDocumentType,
      'urlDoc': urlDoc,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  @override
  List<Object?> get props => [idKmDocument, idDocument, idDocumentType, urlDoc];
}