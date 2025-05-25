class WasteCollection {
  final String id;
  final String userId;
  final String userName;
  final String wasteType;
  final String location;
  final String address;
  final DateTime dateTime;
  final double kilograms;
  final int rewardPoints;
  final String status;
  final DateTime createdAt;

  WasteCollection({
    required this.id,
    required this.userId,
    required this.userName,
    required this.wasteType,
    required this.location,
    required this.address,
    required this.dateTime,
    required this.kilograms,
    required this.rewardPoints,
    this.status = 'pending',
    required this.createdAt,
  });

  factory WasteCollection.fromJson(Map<String, dynamic> json) {
    return WasteCollection(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      wasteType: json['wasteType'] ?? '',
      location: json['location'] ?? '',
      address: json['address'] ?? '',
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'])
          : DateTime.now(),
      kilograms: json['kilograms']?.toDouble() ?? 0.0,
      rewardPoints: json['rewardPoints'] ?? 0,
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'wasteType': wasteType,
      'location': location,
      'address': address,
      'dateTime': dateTime.toIso8601String(),
      'kilograms': kilograms,
      'rewardPoints': rewardPoints,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
