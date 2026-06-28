import 'package:equatable/equatable.dart';

class KmbusDocument extends Equatable {
  final int? idKmDocument;
  final int idDocument;
  final int idDocumentType;

  const KmbusDocument({
    this.idKmDocument,
    required this.idDocument,
    required this.idDocumentType,
  });

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
    );
  }

  factory KmbusDocument.fromJson(Map<String, dynamic> json) {
    return KmbusDocument(
      idKmDocument: json['id_detail_document'] ?? json['idKmDocument'],
      idDocument: json['id_document'] ?? json['idDocument'] ?? 0,
      idDocumentType: json['id_document_type'] ?? json['idDocumentType'] ?? 0,
    );
  }

  factory KmbusDocument.fromMap(Map<String, dynamic> map) => KmbusDocument.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      'idKmDocument': idKmDocument,
      'idDocument': idDocument,
      'idDocumentType': idDocumentType,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  @override
  List<Object?> get props => [idKmDocument, idDocument, idDocumentType];
}