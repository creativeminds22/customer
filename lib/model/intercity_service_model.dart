class IntercityServiceModel {
  String? image;
  bool? enable;
  String? kmCharge;
  String? name;
  bool? offerRate;
  String? id;

  IntercityServiceModel({this.image, this.enable, this.kmCharge, this.name, this.offerRate, this.id});

  IntercityServiceModel.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    enable = json['enable'];
    kmCharge = json['kmCharge'];
    name = json['name'];
    offerRate = json['offerRate'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['enable'] = enable;
    data['kmCharge'] = kmCharge;
    data['name'] = name;
    data['offerRate'] = offerRate;
    data['id'] = id;
    return data;
  }
}
