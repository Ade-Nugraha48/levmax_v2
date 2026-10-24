/// Model data untuk kustomisasi Persona & Identitas AI Guide (Gemini)
class AIPersona {
  final String name;
  final String identity;
  final String tone;
  final String traits;
  final String? avatarPath;

  const AIPersona({
    required this.name,
    required this.identity,
    required this.tone,
    required this.traits,
    this.avatarPath,
  });

  /// Persona bawaan System Guide Solo Leveling
  static AIPersona get defaultPersona => const AIPersona(
        name: 'SYSTEM GUIDE',
        identity: 'HUNTER SUPPORT AI',
        tone: 'Formal, Dingin & Otoritatif (Gaya Sistem Solo Leveling)',
        traits:
            'Tegas, analitis, sangat berdedikasi memantau perkembangan fisik dan rank Hunter, berbicara lugas dan efisien.',
      );

  AIPersona copyWith({
    String? name,
    String? identity,
    String? tone,
    String? traits,
    String? avatarPath,
    bool clearAvatar = false,
  }) {
    return AIPersona(
      name: name ?? this.name,
      identity: identity ?? this.identity,
      tone: tone ?? this.tone,
      traits: traits ?? this.traits,
      avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'identity': identity,
        'tone': tone,
        'traits': traits,
        'avatarPath': avatarPath,
      };

  factory AIPersona.fromJson(Map<String, dynamic> json) {
    return AIPersona(
      name: json['name']?.toString() ?? 'SYSTEM GUIDE',
      identity: json['identity']?.toString() ?? 'HUNTER SUPPORT AI',
      tone: json['tone']?.toString() ??
          'Formal, Dingin & Otoritatif (Gaya Sistem Solo Leveling)',
      traits: json['traits']?.toString() ??
          'Tegas, analitis, sangat berdedikasi memantau perkembangan fisik dan rank Hunter, berbicara lugas dan efisien.',
      avatarPath: json['avatarPath']?.toString(),
    );
  }
}
