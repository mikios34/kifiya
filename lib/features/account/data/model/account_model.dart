class AccountModel {
  final int id;
  final String accountNumber;
  final double balance;
  final int userId;
  final AccountType accountType;

  const AccountModel({
    required this.id,
    required this.accountNumber,
    required this.balance,
    required this.userId,
    required this.accountType,
  });

  // Factory constructor to create AccountModel from JSON
  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as int,
      accountNumber: json['accountNumber'] as String,
      balance: (json['balance'] as num).toDouble(),
      userId: json['userId'] as int,
      accountType: AccountType.values.firstWhere(
        (type) =>
            type.name.toUpperCase() ==
            (json['accountType'] as String).toUpperCase(),
        orElse: () => AccountType.checking,
      ),
    );
  }

  // Method to convert AccountModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountNumber': accountNumber,
      'balance': balance,
      'userId': userId,
      'accountType': accountType.name.toUpperCase(),
    };
  }

  // CopyWith method for creating modified copies
  AccountModel copyWith({
    int? id,
    String? accountNumber,
    double? balance,
    int? userId,
    AccountType? accountType,
  }) {
    return AccountModel(
      id: id ?? this.id,
      accountNumber: accountNumber ?? this.accountNumber,
      balance: balance ?? this.balance,
      userId: userId ?? this.userId,
      accountType: accountType ?? this.accountType,
    );
  }

  // Override equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccountModel &&
        other.id == id &&
        other.accountNumber == accountNumber &&
        other.balance == balance &&
        other.userId == userId &&
        other.accountType == accountType;
  }

  // Override hashCode
  @override
  int get hashCode {
    return Object.hash(id, accountNumber, balance, userId, accountType);
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'AccountModel(id: $id, accountNumber: $accountNumber, balance: $balance, userId: $userId, accountType: $accountType)';
  }

  // Getter for formatted balance
  String get formattedBalance => '\$${balance.toStringAsFixed(2)}';

  // Getter for masked account number
  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    final lastFour = accountNumber.substring(accountNumber.length - 4);
    return '**** **** **** $lastFour';
  }
}

// Account type enum
enum AccountType {
  checking,
  savings,
  business,
  investment;

  String get displayName {
    switch (this) {
      case AccountType.checking:
        return 'Checking';
      case AccountType.savings:
        return 'Savings';
      case AccountType.business:
        return 'Business';
      case AccountType.investment:
        return 'Investment';
    }
  }
}

// Create account request model
class CreateAccountRequest {
  final AccountType accountType;
  final double initialBalance;

  const CreateAccountRequest({
    required this.accountType,
    required this.initialBalance,
  });

  Map<String, dynamic> toJson() {
    return {
      'accountType': accountType.name.toUpperCase(),
      'initialBalance': initialBalance,
    };
  }

  @override
  String toString() {
    return 'CreateAccountRequest(accountType: $accountType, initialBalance: $initialBalance)';
  }
}
