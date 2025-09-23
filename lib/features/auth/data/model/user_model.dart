class UserModel {
  final String username;
  final String passwordHash;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  const UserModel({
    required this.username,
    required this.passwordHash,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  // Factory constructor to create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] as String,
      passwordHash: json['passwordHash'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );
  }

  // Method to convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'passwordHash': passwordHash,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  // CopyWith method for creating modified copies
  UserModel copyWith({
    String? username,
    String? passwordHash,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
  }) {
    return UserModel(
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  // Override equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.username == username &&
        other.passwordHash == passwordHash &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.email == email &&
        other.phoneNumber == phoneNumber;
  }

  // Override hashCode
  @override
  int get hashCode {
    return Object.hash(
      username,
      passwordHash,
      firstName,
      lastName,
      email,
      phoneNumber,
    );
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'UserModel(username: $username, firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber)';
  }

  // Getter for full name
  String get fullName => '$firstName $lastName';
}
