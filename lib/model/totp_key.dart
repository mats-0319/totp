class TOTPKey {
  String name = "";
  String key = "";
  bool autoActive = false; // be active when app start
  bool isDeleted = false; // shadow on home page

  TOTPKey(this.name, this.key, this.autoActive);

  TOTPKey.empty();

  TOTPKey.deepCopy(TOTPKey k)
    : name = k.name,
      key = k.key,
      autoActive = k.autoActive,
      isDeleted = k.isDeleted;

  TOTPKey.fromJson(Map<String, dynamic> json) {
    name = json["name"] as String? ?? "";
    key = json["key"] as String? ?? "";
    autoActive = json["autoActive"] as bool? ?? false;
    isDeleted = json["isDeleted"] as bool? ?? false;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "name": name,
      "key": key,
      "autoActive": autoActive,
      "isDeleted": isDeleted,
    };
  }
}

void copyBack(TOTPKey origin, TOTPKey newIns) {
  origin.name = newIns.name;
  origin.key = newIns.key;
  origin.autoActive = newIns.autoActive;
  origin.isDeleted = newIns.isDeleted;
}
