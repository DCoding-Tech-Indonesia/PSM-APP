abstract class ChecklistInputEvent {
  const ChecklistInputEvent();
}

class LoadChecklistQuestions extends ChecklistInputEvent {
  final String tipeForm;

  const LoadChecklistQuestions(this.tipeForm);
}

class SubmitChecklist extends ChecklistInputEvent {
  final Map<String, dynamic> payload;

  const SubmitChecklist(this.payload);
}
