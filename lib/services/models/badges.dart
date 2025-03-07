class Badge {
  String _badgeId = "";
  String _name = "";
  String description = "";
  String _image = "";
  int _points = 0;
  int _pointsToAchieve = 0;

  Badge(this._name, this.description, this._image, this._points,
      this._pointsToAchieve);

  String get getBadgeId => _badgeId;
  String get getName => _name;
  String get getDescription => description;
  String get getImage => _image;
  int get getPoints => _points;
  int get getPointsToAchieve => _pointsToAchieve;

  set setBadgeId(String newBadgeId) {
    _badgeId = newBadgeId;
  }

  set setName(String newName) {
    _name = newName;
  }

  set setDescription(String newDescription) {
    description = newDescription;
  }

  set setImage(String newImage) {
    _image = newImage;
  }

  set setPoints(int newPoints) {
    _points = newPoints;
  }

  set setPointsToAchieve(int newPointsToAchieve) {
    _pointsToAchieve = newPointsToAchieve;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["badgeId"] = _badgeId;
    map["name"] = _name;
    map["description"] = description;
    map["image"] = _image;
    map["points"] = _points;
    map["pointsToAchieve"] = _pointsToAchieve;
    return map;
  }

  Badge.fromObject(dynamic o) {
    _badgeId = o["badgeId"];
    _name = o["name"];
    description = o["description"];
    _image = o["image"];
    _points = o["points"];
    _pointsToAchieve = o["pointsToAchieve"];
  }
}
