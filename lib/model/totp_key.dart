class TOTPKey {
  String name = "";
  String key = "";
  bool autoActive = false; // be active when app start
  bool isDeleted = false; // shadow on home page

  TOTPKey(this.key, this.name, this.autoActive);

  TOTPKey.empty();

  TOTPKey.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    key = json["key"];
    autoActive = json["autoActive"];
    isDeleted = json["isDeleted"];
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
