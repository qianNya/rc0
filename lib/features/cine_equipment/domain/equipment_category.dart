enum EquipmentCategory {
  cinema,
  photo,
  vintage,
  favorites,
}

extension EquipmentCategoryLabel on EquipmentCategory {
  String get label {
    switch (this) {
      case EquipmentCategory.cinema:
        return '电影机';
      case EquipmentCategory.photo:
        return '摄影机';
      case EquipmentCategory.vintage:
        return '复古';
      case EquipmentCategory.favorites:
        return '收藏';
    }
  }
}

enum EquipmentItemKind {
  body,
  lens,
  setup,
}
