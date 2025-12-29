/// 🎭 User Character Model - Representing Nepal's Beautiful Diversity
/// 
/// This model represents a user's customized character that reflects
/// Nepal's rich cultural and ethnic diversity, allowing every user
/// to see themselves represented in their learning journey.
class UserCharacter {
  final String id;
  final String name;
  final NepalEthnicity ethnicity;
  final Gender gender;
  final SkinTone skinTone;
  final HairStyle hairStyle;
  final ClothingStyle clothing;
  final AccessoryStyle accessories;
  final String? customMessage;
  final DateTime createdAt;

  const UserCharacter({
    required this.id,
    required this.name,
    required this.ethnicity,
    required this.gender,
    required this.skinTone,
    required this.hairStyle,
    required this.clothing,
    required this.accessories,
    this.customMessage,
    required this.createdAt,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ethnicity': ethnicity.name,
      'gender': gender.name,
      'skinTone': skinTone.name,
      'hairStyle': hairStyle.name,
      'clothing': clothing.name,
      'accessories': accessories.name,
      'customMessage': customMessage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory UserCharacter.fromJson(Map<String, dynamic> json) {
    return UserCharacter(
      id: json['id'],
      name: json['name'],
      ethnicity: NepalEthnicity.values.firstWhere(
        (e) => e.name == json['ethnicity'],
        orElse: () => NepalEthnicity.chhetri,
      ),
      gender: Gender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => Gender.other,
      ),
      skinTone: SkinTone.values.firstWhere(
        (e) => e.name == json['skinTone'],
        orElse: () => SkinTone.medium,
      ),
      hairStyle: HairStyle.values.firstWhere(
        (e) => e.name == json['hairStyle'],
        orElse: () => HairStyle.straight,
      ),
      clothing: ClothingStyle.values.firstWhere(
        (e) => e.name == json['clothing'],
        orElse: () => ClothingStyle.casual,
      ),
      accessories: AccessoryStyle.values.firstWhere(
        (e) => e.name == json['accessories'],
        orElse: () => AccessoryStyle.none,
      ),
      customMessage: json['customMessage'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// Create a copy with updated fields
  UserCharacter copyWith({
    String? name,
    NepalEthnicity? ethnicity,
    Gender? gender,
    SkinTone? skinTone,
    HairStyle? hairStyle,
    ClothingStyle? clothing,
    AccessoryStyle? accessories,
    String? customMessage,
  }) {
    return UserCharacter(
      id: id,
      name: name ?? this.name,
      ethnicity: ethnicity ?? this.ethnicity,
      gender: gender ?? this.gender,
      skinTone: skinTone ?? this.skinTone,
      hairStyle: hairStyle ?? this.hairStyle,
      clothing: clothing ?? this.clothing,
      accessories: accessories ?? this.accessories,
      customMessage: customMessage ?? this.customMessage,
      createdAt: createdAt,
    );
  }

  /// Get the character's emoji representation for quick display
  String get emoji {
    return ethnicity.getEmoji(gender, skinTone);
  }

  /// Get the character's traditional greeting
  String get greeting {
    return ethnicity.traditionalGreeting;
  }

  /// Get the character's cultural description
  String get culturalDescription {
    return ethnicity.description;
  }
}

/// 🏔️ Nepal's Major Ethnic Groups
/// Based on Nepal's 2021 census and cultural diversity
enum NepalEthnicity {
  // Khas Arya Groups (Indo-Aryan)
  chhetri('Chhetri', 'नमस्ते', 'The largest ethnic group in Nepal, traditionally warriors and administrators'),
  bahunBrahmin('Bahun/Brahmin', 'नमस्ते', 'Traditionally priests and scholars, keepers of Hindu traditions'),
  thakuri('Thakuri', 'नमस्ते', 'Royal and noble families, including former ruling dynasties'),
  
  // Janajati Groups (Indigenous)
  magar('Magar', 'नमस्ते', 'Brave warriors from western hills, known for military service'),
  tamang('Tamang', 'तशी देलेक', 'Tibetan-origin people, rich in Buddhist culture and traditions'),
  newar('Newar', 'नमस्कार', 'Indigenous people of Kathmandu valley, master craftsmen and traders'),
  rai('Rai', 'नमस्ते', 'Kirant people from eastern hills, skilled farmers and warriors'),
  gurung('Gurung', 'नमस्ते', 'Mountain people known for bravery and Gurkha military service'),
  limbu('Limbu', 'नमस्ते', 'Kirant people with rich oral traditions and unique script'),
  sherpa('Sherpa', 'तशी देलेक', 'High-altitude mountain people, famous for mountaineering skills'),
  tharu('Tharu', 'नमस्ते', 'Indigenous people of Terai plains, skilled in agriculture'),
  
  // Madhesi Groups (Terai)
  madhesi('Madhesi', 'नमस्ते', 'People of Terai plains with close cultural ties to India'),
  muslim('Muslim', 'अस्सलामु अलैकुम', 'Muslim communities contributing to Nepal\'s diversity'),
  
  // Other Indigenous Groups
  chepang('Chepang', 'नमस्ते', 'Indigenous forest people with unique hunting and gathering traditions'),
  raute('Raute', 'नमस्ते', 'Nomadic people, one of Nepal\'s most unique communities'),
  kusunda('Kusunda', 'नमस्ते', 'Ancient hunter-gatherer people with their own language family'),
  
  // Tibetan Groups
  tibetan('Tibetan', 'तशी देलेक', 'Tibetan refugees and communities in high mountain regions'),
  
  // Mixed/Other
  mixed('Mixed Heritage', 'नमस्ते', 'Beautiful blend of Nepal\'s diverse ethnic backgrounds'),
  other('Other', 'नमस्ते', 'Other ethnic communities that make Nepal diverse and beautiful');

  const NepalEthnicity(this.displayName, this.traditionalGreeting, this.description);

  final String displayName;
  final String traditionalGreeting;
  final String description;

  /// Get appropriate emoji based on gender and skin tone
  String getEmoji(Gender gender, SkinTone skinTone) {
    // Base emojis for different ethnicities and genders
    switch (this) {
      case NepalEthnicity.sherpa:
      case NepalEthnicity.tibetan:
        return gender == Gender.female ? '👩‍🏔️' : '👨‍🏔️';
      case NepalEthnicity.newar:
        return gender == Gender.female ? '👩‍🎨' : '👨‍🎨';
      case NepalEthnicity.tharu:
        return gender == Gender.female ? '👩‍🌾' : '👨‍🌾';
      case NepalEthnicity.magar:
      case NepalEthnicity.gurung:
        return gender == Gender.female ? '👩‍✈️' : '👨‍✈️';
      case NepalEthnicity.bahunBrahmin:
        return gender == Gender.female ? '👩‍🏫' : '👨‍🏫';
      case NepalEthnicity.madhesi:
        return gender == Gender.female ? '👩‍💼' : '👨‍💼';
      default:
        return gender == Gender.female ? '👩‍🎓' : (gender == Gender.male ? '👨‍🎓' : '🧑‍🎓');
    }
  }

  /// Get traditional clothing emoji
  String get clothingEmoji {
    switch (this) {
      case NepalEthnicity.newar:
        return '🥻'; // Traditional Newari dress
      case NepalEthnicity.sherpa:
      case NepalEthnicity.tibetan:
        return '🧥'; // Traditional Tibetan robes
      case NepalEthnicity.tharu:
        return '👗'; // Tharu traditional dress
      default:
        return '👔'; // General traditional wear
    }
  }
}

/// 👥 Gender Options (Inclusive)
enum Gender {
  male('Male', '👨'),
  female('Female', '👩'),
  other('Other/Non-binary', '🧑');

  const Gender(this.displayName, this.emoji);
  final String displayName;
  final String emoji;
}

/// 🎨 Skin Tone Options (Representing Nepal's Diversity)
enum SkinTone {
  light('Light', '🏻'),
  mediumLight('Medium Light', '🏼'),
  medium('Medium', '🏽'),
  mediumDark('Medium Dark', '🏾'),
  dark('Dark', '🏿');

  const SkinTone(this.displayName, this.modifier);
  final String displayName;
  final String modifier;
}

/// 💇 Hair Style Options
enum HairStyle {
  straight('Straight Hair', '💇‍♀️'),
  wavy('Wavy Hair', '💇‍♂️'),
  curly('Curly Hair', '💇'),
  braided('Braided Hair', '👩‍🦱'),
  short('Short Hair', '👨‍🦲'),
  long('Long Hair', '👩‍🦳'),
  traditional('Traditional Style', '👳');

  const HairStyle(this.displayName, this.emoji);
  final String displayName;
  final String emoji;
}

/// 👕 Clothing Style Options
enum ClothingStyle {
  casual('Casual Wear', '👕'),
  traditional('Traditional Dress', '🥻'),
  formal('Formal Wear', '👔'),
  student('Student Uniform', '🎓'),
  cultural('Cultural Attire', '👘'),
  modern('Modern Style', '👗');

  const ClothingStyle(this.displayName, this.emoji);
  final String displayName;
  final String emoji;
}

/// 💍 Accessory Options
enum AccessoryStyle {
  none('No Accessories', ''),
  glasses('Glasses', '👓'),
  hat('Traditional Hat', '👒'),
  jewelry('Traditional Jewelry', '💍'),
  scarf('Scarf/Shawl', '🧣'),
  flowers('Flower Garland', '🌸');

  const AccessoryStyle(this.displayName, this.emoji);
  final String displayName;
  final String emoji;
}

/// 🎭 Character Presets for Quick Selection
class CharacterPresets {
  static List<UserCharacter> getPresets() {
    return [
      // Sherpa Mountain Guide
      UserCharacter(
        id: 'preset_sherpa',
        name: 'Pemba',
        ethnicity: NepalEthnicity.sherpa,
        gender: Gender.male,
        skinTone: SkinTone.medium,
        hairStyle: HairStyle.short,
        clothing: ClothingStyle.traditional,
        accessories: AccessoryStyle.hat,
        customMessage: 'Ready to climb mountains of knowledge!',
        createdAt: DateTime.now(),
      ),
      
      // Newar Artist
      UserCharacter(
        id: 'preset_newar',
        name: 'Sujata',
        ethnicity: NepalEthnicity.newar,
        gender: Gender.female,
        skinTone: SkinTone.mediumLight,
        hairStyle: HairStyle.braided,
        clothing: ClothingStyle.cultural,
        accessories: AccessoryStyle.jewelry,
        customMessage: 'Art and learning go hand in hand!',
        createdAt: DateTime.now(),
      ),
      
      // Tharu Farmer
      UserCharacter(
        id: 'preset_tharu',
        name: 'Rajesh',
        ethnicity: NepalEthnicity.tharu,
        gender: Gender.male,
        skinTone: SkinTone.mediumDark,
        hairStyle: HairStyle.straight,
        clothing: ClothingStyle.traditional,
        accessories: AccessoryStyle.hat,
        customMessage: 'Growing knowledge like crops in the field!',
        createdAt: DateTime.now(),
      ),
      
      // Gurung Student
      UserCharacter(
        id: 'preset_gurung',
        name: 'Maya',
        ethnicity: NepalEthnicity.gurung,
        gender: Gender.female,
        skinTone: SkinTone.medium,
        hairStyle: HairStyle.long,
        clothing: ClothingStyle.student,
        accessories: AccessoryStyle.glasses,
        customMessage: 'Brave in battle, brilliant in books!',
        createdAt: DateTime.now(),
      ),
      
      // Mixed Heritage Modern
      UserCharacter(
        id: 'preset_mixed',
        name: 'Alex',
        ethnicity: NepalEthnicity.mixed,
        gender: Gender.other,
        skinTone: SkinTone.mediumLight,
        hairStyle: HairStyle.modern,
        clothing: ClothingStyle.modern,
        accessories: AccessoryStyle.glasses,
        customMessage: 'Embracing all cultures, learning everything!',
        createdAt: DateTime.now(),
      ),
    ];
  }
}