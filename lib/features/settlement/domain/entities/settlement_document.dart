import 'package:equatable/equatable.dart';

class SettlementDocument extends Equatable{
  final int idDocument;
  final int idDocumentType;

  SettlementDocument({required this.idDocument, required this.idDocumentType});

  factory SettlementDocument.fromJson(Map<String, dynamic> json) {
    return SettlementDocument(
      idDocument: json['idDocument'] ?? 0,
      idDocumentType: json['idDocumentType'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "idDocument": idDocument,
    "idDocumentType": idDocumentType,
  };

  @override
  List<Object?> get props => [idDocument, idDocumentType];
}
