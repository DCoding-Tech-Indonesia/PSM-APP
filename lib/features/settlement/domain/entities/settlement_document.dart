import 'package:equatable/equatable.dart';

class SettlementDocument extends Equatable{
  final int idDocument;
  final int idDocumentType;

  SettlementDocument({required this.idDocument, required this.idDocumentType});

  Map<String, dynamic> toJson() => {
    "idDocument": idDocument,
    "idDocumentType": idDocumentType,
  };

  @override
  List<Object?> get props => [idDocument, idDocumentType];
}
