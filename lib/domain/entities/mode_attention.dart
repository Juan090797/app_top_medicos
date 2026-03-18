class ModeAttention {
  final int doctorId;
  final int modesAttentionId;
  final String description; // "P" o "O"

  const ModeAttention({
    required this.doctorId,
    required this.modesAttentionId,
    required this.description,
  });
}
