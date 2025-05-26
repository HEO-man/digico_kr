class DigimonEntry {
  final String name;
  final String folderName;

  DigimonEntry({required this.name, required this.folderName});

  factory DigimonEntry.fromJson(Map<String, dynamic> json) {
    return DigimonEntry(
      name: json['name'] ?? '',
      folderName: json['folderName'] ?? json['id'] ?? '',
    );
  }
}