class TOTPKey {
  String key = "";
  String name = "";
  bool autoActive = false; // be active when app start
  bool isDeleted = false;

  TOTPKey(this.key, this.name, this.autoActive);
  TOTPKey.all(this.key, this.name, this.autoActive, this.isDeleted);
  TOTPKey.empty();

  TOTPKey.fromJson(Map<String, dynamic> json) {
    key = json["key"];
    name = json["name"];
    autoActive = json["autoActive"];
    isDeleted = json["isDeleted"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data["key"] = key;
    data["name"] = name;
    data["autoActive"] = autoActive;
    data["isDeleted"] = isDeleted;

    return data;
  }
}
