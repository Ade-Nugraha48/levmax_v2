class QuestModel {
  final String id;
  final String title;
  final String category; // Workout, Cardio, Appearance, Study
  final int expReward;
  final int goldReward;
  final bool isCompleted;

  const QuestModel({
    required this.id,
    required this.title,
    required this.category,
    required this.expReward,
    required this.goldReward,
    this.isCompleted = false,
  });

  QuestModel copyWith({bool? isCompleted}) {
    return QuestModel(
      id: id,
      title: title,
      category: category,
      expReward: expReward,
      goldReward: goldReward,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
