import 'package:equatable/equatable.dart';

class SettlementDocument extends Equatable {
  final int? idDetailDocument;
  final int idDocument;
  final int idDocumentType;
  final String? urlDoc;

  SettlementDocument({
    this.idDetailDocument,
    required this.idDocument,
    required this.idDocumentType,
    this.urlDoc,
  });

  factory SettlementDocument.fromJson(Map<String, dynamic> json) {
    return SettlementDocument(
      idDetailDocument: json['idDetailDocument'],
      idDocument: json['idDocument'] ?? 0,
      idDocumentType: json['idDocumentType'] ?? 0,
      urlDoc: json['urlDoc'],
    );
  }

  Map<String, dynamic> toJson() => {
    "idDetailDocument": idDetailDocument,
    "idDocument": idDocument,
    "idDocumentType": idDocumentType
  };

  @override
  List<Object?> get props => [idDetailDocument, idDocument, idDocumentType, urlDoc];
}