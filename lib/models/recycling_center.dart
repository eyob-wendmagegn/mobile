class RecyclingCenter {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final List<String> acceptedWasteTypes;
  final String operatingHours;

  RecyclingCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.acceptedWasteTypes,
    required this.operatingHours,
  });

  factory RecyclingCenter.fromJson(Map<String, dynamic> json) {
    return RecyclingCenter(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      acceptedWasteTypes: List<String>.from(json['acceptedWasteTypes'] ?? []),
      operatingHours: json['operatingHours'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'acceptedWasteTypes': acceptedWasteTypes,
      'operatingHours': operatingHours,
    };
  }
}
