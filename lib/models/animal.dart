class Animal {
  const Animal({
    this.animalId,
    this.animalSubid,
    this.animalAreaPkid,
    this.animalShelterPkid,
    this.animalPlace,
    this.animalKind,
    this.animalVariety,
    this.animalSex,
    this.animalBodytype,
    this.animalColour,
    this.animalAge,
    this.animalSterilization,
    this.animalBacterin,
    this.animalFoundplace,
    this.animalTitle,
    this.animalStatus,
    this.animalRemark,
    this.animalCaption,
    this.animalOpendate,
    this.animalCloseddate,
    this.animalUpdate,
    this.animalCreatetime,
    this.shelterName,
    this.albumFile,
    this.albumUpdate,
    this.cDate,
    this.shelterAddress,
    this.shelterTel,
  });

  final int? animalId;
  final String? animalSubid;
  final int? animalAreaPkid;
  final int? animalShelterPkid;
  final String? animalPlace;
  final String? animalKind;
  final String? animalVariety;
  final String? animalSex;
  final String? animalBodytype;
  final String? animalColour;
  final String? animalAge;
  final String? animalSterilization;
  final String? animalBacterin;
  final String? animalFoundplace;
  final String? animalTitle;
  final String? animalStatus;
  final String? animalRemark;
  final String? animalCaption;
  final String? animalOpendate;
  final String? animalCloseddate;
  final String? animalUpdate;
  final String? animalCreatetime;
  final String? shelterName;
  final String? albumFile;
  final String? albumUpdate;
  final String? cDate;
  final String? shelterAddress;
  final String? shelterTel;

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      animalId: _asInt(json['animal_id']),
      animalSubid: _asString(json['animal_subid']),
      animalAreaPkid: _asInt(json['animal_area_pkid']),
      animalShelterPkid: _asInt(json['animal_shelter_pkid']),
      animalPlace: _asString(json['animal_place']),
      animalKind: _asString(json['animal_kind']),
      animalVariety: _asString(json['animal_Variety']),
      animalSex: _asString(json['animal_sex']),
      animalBodytype: _asString(json['animal_bodytype']),
      animalColour: _asString(json['animal_colour']),
      animalAge: _asString(json['animal_age']),
      animalSterilization: _asString(json['animal_sterilization']),
      animalBacterin: _asString(json['animal_bacterin']),
      animalFoundplace: _asString(json['animal_foundplace']),
      animalTitle: _asString(json['animal_title']),
      animalStatus: _asString(json['animal_status']),
      animalRemark: _asString(json['animal_remark']),
      animalCaption: _asString(json['animal_caption']),
      animalOpendate: _asString(json['animal_opendate']),
      animalCloseddate: _asString(json['animal_closeddate']),
      animalUpdate: _asString(json['animal_update']),
      animalCreatetime: _asString(json['animal_createtime']),
      shelterName: _asString(json['shelter_name']),
      albumFile: _asString(json['album_file']),
      albumUpdate: _asString(json['album_update']),
      cDate: _asString(json['cDate']),
      shelterAddress: _asString(json['shelter_address']),
      shelterTel: _asString(json['shelter_tel']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animal_id': animalId,
      'animal_subid': animalSubid,
      'animal_area_pkid': animalAreaPkid,
      'animal_shelter_pkid': animalShelterPkid,
      'animal_place': animalPlace,
      'animal_kind': animalKind,
      'animal_Variety': animalVariety,
      'animal_sex': animalSex,
      'animal_bodytype': animalBodytype,
      'animal_colour': animalColour,
      'animal_age': animalAge,
      'animal_sterilization': animalSterilization,
      'animal_bacterin': animalBacterin,
      'animal_foundplace': animalFoundplace,
      'animal_title': animalTitle,
      'animal_status': animalStatus,
      'animal_remark': animalRemark,
      'animal_caption': animalCaption,
      'animal_opendate': animalOpendate,
      'animal_closeddate': animalCloseddate,
      'animal_update': animalUpdate,
      'animal_createtime': animalCreatetime,
      'shelter_name': shelterName,
      'album_file': albumFile,
      'album_update': albumUpdate,
      'cDate': cDate,
      'shelter_address': shelterAddress,
      'shelter_tel': shelterTel,
    };
  }

  Animal copyWith({
    int? animalId,
    String? animalSubid,
    int? animalAreaPkid,
    int? animalShelterPkid,
    String? animalPlace,
    String? animalKind,
    String? animalVariety,
    String? animalSex,
    String? animalBodytype,
    String? animalColour,
    String? animalAge,
    String? animalSterilization,
    String? animalBacterin,
    String? animalFoundplace,
    String? animalTitle,
    String? animalStatus,
    String? animalRemark,
    String? animalCaption,
    String? animalOpendate,
    String? animalCloseddate,
    String? animalUpdate,
    String? animalCreatetime,
    String? shelterName,
    String? albumFile,
    String? albumUpdate,
    String? cDate,
    String? shelterAddress,
    String? shelterTel,
  }) {
    return Animal(
      animalId: animalId ?? this.animalId,
      animalSubid: animalSubid ?? this.animalSubid,
      animalAreaPkid: animalAreaPkid ?? this.animalAreaPkid,
      animalShelterPkid: animalShelterPkid ?? this.animalShelterPkid,
      animalPlace: animalPlace ?? this.animalPlace,
      animalKind: animalKind ?? this.animalKind,
      animalVariety: animalVariety ?? this.animalVariety,
      animalSex: animalSex ?? this.animalSex,
      animalBodytype: animalBodytype ?? this.animalBodytype,
      animalColour: animalColour ?? this.animalColour,
      animalAge: animalAge ?? this.animalAge,
      animalSterilization: animalSterilization ?? this.animalSterilization,
      animalBacterin: animalBacterin ?? this.animalBacterin,
      animalFoundplace: animalFoundplace ?? this.animalFoundplace,
      animalTitle: animalTitle ?? this.animalTitle,
      animalStatus: animalStatus ?? this.animalStatus,
      animalRemark: animalRemark ?? this.animalRemark,
      animalCaption: animalCaption ?? this.animalCaption,
      animalOpendate: animalOpendate ?? this.animalOpendate,
      animalCloseddate: animalCloseddate ?? this.animalCloseddate,
      animalUpdate: animalUpdate ?? this.animalUpdate,
      animalCreatetime: animalCreatetime ?? this.animalCreatetime,
      shelterName: shelterName ?? this.shelterName,
      albumFile: albumFile ?? this.albumFile,
      albumUpdate: albumUpdate ?? this.albumUpdate,
      cDate: cDate ?? this.cDate,
      shelterAddress: shelterAddress ?? this.shelterAddress,
      shelterTel: shelterTel ?? this.shelterTel,
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString());
  }

  static String? _asString(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}

enum AnimalFilterCategory { all, dog, cat, other }

enum HomeAnimalsSection { recommend, newArrival, waiting, shelter }

extension AnimalX on Animal {
  String get sexText {
    switch (animalSex) {
      case 'M':
        return '公';
      case 'F':
        return '母';
      case 'N':
        return '未標示';
      default:
        return '未標示';
    }
  }

  String get ageText {
    switch (animalAge) {
      case 'CHILD':
        return '幼年';
      case 'ADULT':
        return '成年';
      default:
        return animalAge ?? '未知';
    }
  }

  String get bodyTypeText {
    switch (animalBodytype) {
      case 'SMALL':
        return '小型';
      case 'MEDIUM':
        return '中型';
      case 'BIG':
        return '大型';
      default:
        return animalBodytype ?? '未知';
    }
  }

  String get bodyTypePetText {
    final suffix = animalKind == '狗' ? '犬' : '';
    switch (animalBodytype) {
      case 'SMALL':
        return '小型$suffix';
      case 'MEDIUM':
        return '中型$suffix';
      case 'BIG':
        return '大型$suffix';
      default:
        return bodyTypeText;
    }
  }

  String get statusText {
    switch (animalStatus) {
      case 'NONE':
        return '未公告';
      case 'OPEN':
        return '開放認養';
      case 'ADOPTED':
        return '已認養';
      case 'OTHER':
        return '其他';
      case 'DEAD':
        return '死亡';
      default:
        return animalStatus ?? '未知';
    }
  }

  bool get isSterilized => animalSterilization == 'T';
  bool get isVaccinated => animalBacterin == 'T';
  bool get hasImage => (albumFile ?? '').isNotEmpty;

  String get sterilizationText {
    switch (animalSterilization) {
      case 'T':
        return '已絕育';
      case 'F':
        return '未絕育';
      case 'N':
        return '未提供';
      default:
        return '未提供';
    }
  }

  String get bacterinText {
    switch (animalBacterin) {
      case 'T':
        return '已施打狂犬病疫苗';
      case 'F':
        return '未施打狂犬病疫苗';
      case 'N':
        return '未提供';
      default:
        return '未提供';
    }
  }

  String get displayName {
    if ((animalTitle ?? '').isNotEmpty) {
      return animalTitle!;
    }
    if ((animalVariety ?? '').isNotEmpty) {
      return animalVariety!;
    }
    return '等待認養的毛孩';
  }

  String get headlineTitle {
    final parts = <String>[
      if ((animalColour ?? '').isNotEmpty) animalColour!,
      if ((animalVariety ?? '').isNotEmpty) animalVariety!,
    ];
    if (parts.isNotEmpty) {
      return parts.join();
    }
    return displayName;
  }

  AnimalFilterCategory get filterCategory {
    switch (animalKind) {
      case '狗':
        return AnimalFilterCategory.dog;
      case '貓':
        return AnimalFilterCategory.cat;
      default:
        return AnimalFilterCategory.other;
    }
  }

  String get categoryLabel {
    switch (filterCategory) {
      case AnimalFilterCategory.dog:
        return '狗狗';
      case AnimalFilterCategory.cat:
        return '貓咪';
      case AnimalFilterCategory.other:
        return '其他';
      case AnimalFilterCategory.all:
        return '全部';
    }
  }

  String get primaryLocation {
    return shelterName ?? animalPlace ?? shelterAddress ?? '收容資訊待更新';
  }

  String? get cityName {
    final String source =
        shelterAddress ?? animalPlace ?? animalFoundplace ?? '';
    if (source.isEmpty) {
      return null;
    }

    const List<String> cityTokens = [
      '臺北市',
      '台北市',
      '新北市',
      '桃園市',
      '臺中市',
      '台中市',
      '臺南市',
      '台南市',
      '高雄市',
      '基隆市',
      '新竹市',
      '新竹縣',
      '苗栗縣',
      '彰化縣',
      '南投縣',
      '雲林縣',
      '嘉義市',
      '嘉義縣',
      '屏東縣',
      '宜蘭縣',
      '花蓮縣',
      '臺東縣',
      '台東縣',
      '澎湖縣',
      '金門縣',
      '連江縣',
    ];

    for (final token in cityTokens) {
      if (source.contains(token)) {
        return token.replaceAll('臺', '台');
      }
    }

    return null;
  }

  bool matchesKeyword(String keyword) {
    final String normalizedKeyword = keyword.trim().toLowerCase();
    if (normalizedKeyword.isEmpty) {
      return true;
    }

    final List<String?> candidates = [
      displayName,
      animalVariety,
      animalColour,
      animalKind,
      shelterName,
      animalPlace,
      shelterAddress,
      animalFoundplace,
      animalRemark,
    ];

    return candidates.any((value) {
      final String text = (value ?? '').toLowerCase();
      return text.contains(normalizedKeyword);
    });
  }

  String get sourceLocationText {
    if ((animalFoundplace ?? '').isNotEmpty) {
      return '發現地：$animalFoundplace';
    }
    if ((animalPlace ?? '').isNotEmpty) {
      return '收容地：$animalPlace';
    }
    return '來源地待更新';
  }

  String? get notePreview {
    final text = animalRemark ?? animalCaption;
    if ((text ?? '').isEmpty) {
      return null;
    }
    return text;
  }

  bool get isOpenForAdoption => animalStatus == 'OPEN';

  DateTime? get createDate => _parseDate(animalCreatetime);
  DateTime? get openDate => _parseDate(animalOpendate);
  DateTime? get lastUpdateDate =>
      _parseDate(animalUpdate) ?? _parseDate(cDate) ?? _parseDate(albumUpdate);

  int? get daysSinceCreate => _daysSince(createDate);
  int? get daysSinceOpen => _daysSince(openDate);
  int? get daysSinceUpdate => _daysSince(lastUpdateDate);

  String get stayDurationLabel => '來園 ${daysSinceCreate ?? 0} 天';
  String get adoptionDurationLabel => '開放認養 ${daysSinceOpen ?? 0} 天';
  String get updateDurationLabel => '${daysSinceUpdate ?? 0} 天前更新';

  String get createDateLabel => _formatDate(createDate);
  String get openDateLabel => _formatDate(openDate);
  String get updateDateLabel => _formatDate(lastUpdateDate);

  bool get isRecentArrival => (daysSinceCreate ?? 9999) <= 7;

  static DateTime? _parseDate(String? raw) {
    if ((raw ?? '').isEmpty) {
      return null;
    }
    final normalized = raw!.replaceAll('/', '-');
    return DateTime.tryParse(normalized);
  }

  static int? _daysSince(DateTime? date) {
    if (date == null) {
      return null;
    }
    final now = DateTime.now();
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return normalizedNow.difference(normalizedDate).inDays.clamp(0, 99999);
  }

  static String _formatDate(DateTime? date) {
    if (date == null) {
      return '--';
    }
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year/$month/$day';
  }
}
