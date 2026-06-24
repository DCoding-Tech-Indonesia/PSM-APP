abstract class SpmInputEvent {
  const SpmInputEvent();
}

class FetchQuestions extends SpmInputEvent {
  final int idTypePemeriksaan;

  const FetchQuestions(this.idTypePemeriksaan);
}

/// Membuat data SPM baru → POST /pemeriksaan-spm/create
class CreateSpmData extends SpmInputEvent {
  final Map<String, dynamic> payload;

  const CreateSpmData(this.payload);
}

/// Melakukan submit data SPM → POST /workflow/submit
class SubmitSpmCreated extends SpmInputEvent {
  final int idAuditTrail;
  final String reason;

  const SubmitSpmCreated({
    required this.idAuditTrail,
    required this.reason,
  });
}

