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

  static const List<QuestModel> defaultQuests = [
    QuestModel(
      id: 'pushup',
      title: 'Push Up (20 Reps)',
      category: 'WORKOUT',
      expReward: 10,
      goldReward: 5,
    ),
    QuestModel(
      id: 'situp',
      title: 'Sit Up (20 Reps)',
      category: 'WORKOUT',
      expReward: 10,
      goldReward: 5,
    ),
    QuestModel(
      id: 'pullup',
      title: 'Pull Up (10 Reps)',
      category: 'WORKOUT',
      expReward: 15,
      goldReward: 10,
    ),
    QuestModel(
      id: 'squat',
      title: 'Squat (30 Reps)',
      category: 'WORKOUT',
      expReward: 10,
      goldReward: 5,
    ),
    QuestModel(
      id: 'cardio',
      title: 'Cardio Distance Run',
      category: 'CARDIO',
      expReward: 20,
      goldReward: 15,
    ),
    QuestModel(
      id: 'appearance',
      title: 'Protokol Penampilan Hunter',
      category: 'APPEARANCE',
      expReward: 30,
      goldReward: 20,
    ),
    QuestModel(
      id: 'mana_focus',
      title: 'Mana Knowledge Focus',
      category: 'STUDY',
      expReward: 15,
      goldReward: 10,
    ),
  ];
}
