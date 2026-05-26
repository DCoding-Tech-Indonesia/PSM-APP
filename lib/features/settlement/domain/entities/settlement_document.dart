import 'package:equatable/equatable.dart';

class SettlementDocument extends Equatable{
  final int idDocument;
  final int idDocumentType;
  final String? urlDoc;

  SettlementDocument({required this.idDocument, required this.idDocumentType, this.urlDoc});

  factory SettlementDocument.fromJson(Map<String, dynamic> json) {
    return SettlementDocument(
      idDocument: json['idDocument'] ?? 0,
      idDocumentType: json['idDocumentType'] ?? 3,
      urlDoc: json['urlDoc'],
    );
  }

  Map<String, dynamic> toJson() => {
    "idDocument": idDocument,
    "idDocumentType": idDocumentType,
    "urlDoc": urlDoc
  };

  @override
  List<Object?> get props => [idDocument, idDocumentType, urlDoc];
}
