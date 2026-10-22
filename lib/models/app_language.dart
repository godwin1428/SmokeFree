class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String region;
  final String avatarCode;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.region,
    required this.avatarCode,
  });
}

class AppLanguageCatalog {
  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(
      code: '2',
      name: 'English',
      nativeName: 'English',
      region: 'Global',
      avatarCode: 'EN',
    ),
    AppLanguage(
      code: '1',
      name: 'Tamil',
      nativeName: 'தமிழ்',
      region: 'Tamil Nadu',
      avatarCode: 'TA',
    ),
    AppLanguage(
      code: '3',
      name: 'Hindi',
      nativeName: 'हिंदी',
      region: 'National',
      avatarCode: 'HI',
    ),
    AppLanguage(
      code: '4',
      name: 'Telugu',
      nativeName: 'తెలుగు',
      region: 'Andhra & Telangana',
      avatarCode: 'TE',
    ),
    AppLanguage(
      code: '5',
      name: 'Malayalam',
      nativeName: 'മലയാളം',
      region: 'Kerala',
      avatarCode: 'ML',
    ),
    AppLanguage(
      code: '6',
      name: 'Kannada',
      nativeName: 'ಕನ್ನಡ',
      region: 'Karnataka',
      avatarCode: 'KN',
    ),
    AppLanguage(
      code: '7',
      name: 'Marathi',
      nativeName: 'मराठी',
      region: 'Maharashtra',
      avatarCode: 'MR',
    ),
    AppLanguage(
      code: '8',
      name: 'Bengali',
      nativeName: 'বাংলা',
      region: 'West Bengal',
      avatarCode: 'BN',
    ),
    AppLanguage(
      code: '9',
      name: 'Gujarati',
      nativeName: 'ગુજરાતી',
      region: 'Gujarat',
      avatarCode: 'GU',
    ),
    AppLanguage(
      code: '10',
      name: 'Punjabi',
      nativeName: 'ਪੰਜਾਬੀ',
      region: 'Punjab',
      avatarCode: 'PA',
    ),
  ];

  static AppLanguage getLanguageByCode(String code) {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => supportedLanguages[0], // English default
    );
  }

  static AppLanguage getLanguageByName(String nameOrNative) {
    return supportedLanguages.firstWhere(
      (lang) => lang.name.toLowerCase() == nameOrNative.toLowerCase() ||
                lang.nativeName == nameOrNative,
      orElse: () => supportedLanguages[0],
    );
  }
}
