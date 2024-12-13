class SocialLink {
  final String id;
  final String name;
  final String? nameHe; // Hebrew name
  final String? iconPath;
  final String? url;
  final bool isActive;
  final int order;
  final bool isHeader; // Flag to indicate if this is a header

  const SocialLink({
    required this.id,
    required this.name,
    this.nameHe,
    this.iconPath,
    this.url,
    this.isActive = true,
    this.order = 0,
    this.isHeader = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameHe': nameHe,
      'iconPath': iconPath,
      'url': url,
      'isActive': isActive,
      'order': order,
      'isHeader': isHeader,
    };
  }

  factory SocialLink.fromMap(Map<String, dynamic> map) {
    return SocialLink(
      id: map['id'] as String,
      name: map['name'] as String,
      nameHe: map['nameHe'] as String?,
      iconPath: map['iconPath'] as String?,
      url: map['url'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      order: map['order'] as int? ?? 0,
      isHeader: map['isHeader'] as bool? ?? false,
    );
  }

  SocialLink copyWith({
    String? id,
    String? name,
    String? nameHe,
    String? iconPath,
    String? url,
    bool? isActive,
    int? order,
    bool? isHeader,
  }) {
    return SocialLink(
      id: id ?? this.id,
      name: name ?? this.name,
      nameHe: nameHe ?? this.nameHe,
      iconPath: iconPath ?? this.iconPath,
      url: url ?? this.url,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      isHeader: isHeader ?? this.isHeader,
    );
  }
} 