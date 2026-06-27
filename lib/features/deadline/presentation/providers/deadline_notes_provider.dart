import 'package:flutter_riverpod/flutter_riverpod.dart';

final deadlineNotesProvider =
    StateNotifierProvider<DeadlineNotesNotifier, Map<String, String>>(
      (ref) => DeadlineNotesNotifier(),
    );

class DeadlineNotesNotifier extends StateNotifier<Map<String, String>> {
  DeadlineNotesNotifier() : super(const {});

  void saveNote(String deadlineId, String note) {
    final trimmedNote = note.trim();

    if (trimmedNote.isEmpty) {
      final updatedNotes = Map<String, String>.from(state)..remove(deadlineId);
      state = updatedNotes;
      return;
    }

    state = {...state, deadlineId: trimmedNote};
  }
}
