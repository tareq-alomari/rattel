/// Evaluation model for teacher assessments
class EvaluationModel {
  final int? evalId;
  final int memId;
  final int teacherId;
  final double score;
  final String? notes;
  final String status; // 'excellent', 'good', 'needs_improvement'
  final String evaluatedAt;

  EvaluationModel({
    this.evalId,
    required this.memId,
    required this.teacherId,
    required this.score,
    this.notes,
    required this.status,
    required this.evaluatedAt,
  });

  factory EvaluationModel.fromMap(Map<String, dynamic> map) {
    return EvaluationModel(
      evalId: map['eval_id'] as int?,
      memId: map['mem_id'] as int,
      teacherId: map['teacher_id'] as int,
      score: (map['score'] as num).toDouble(),
      notes: map['notes'] as String?,
      status: map['status'] as String,
      evaluatedAt: map['evaluated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eval_id': evalId,
      'mem_id': memId,
      'teacher_id': teacherId,
      'score': score,
      'notes': notes,
      'status': status,
      'evaluated_at': evaluatedAt,
    };
  }
}
