// digimon_utils.dart

String elementKey(String e) {
  switch (e) {
    case '불':
      return 'fire';
    case '물':
      return 'water';
    case '풀':
      return 'nature';
    case '땅':
      return 'earth';
    case '바람':
      return 'wind';
    case '전기':
      return 'thunder';
    case '빛':
      return 'light';
    case '어둠':
      return 'dark';
    default:
      return 'unknown';
  }
}

String typeKey(String type) {
  switch (type) {
    case '백신':
      return 'ic_vaccine';
    case '바이러스':
      return 'ic_virus';
    case '데이터':
      return 'ic_data';
    default:
      return 'unknown';
  }
}

String? matchElement(String? value) {
  const elements = ['불', '물', '풀', '땅', '바람', '전기', '빛', '어둠'];
  return elements.contains(value) ? value : null;
}

String? matchType(String? value) {
  const types = ['백신', '바이러스', '데이터'];
  return types.contains(value) ? value : null;
}