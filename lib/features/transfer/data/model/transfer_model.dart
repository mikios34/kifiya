class TransferRequest {
  final String fromAccountNumber;
  final String toAccountNumber;
  final double amount;

  const TransferRequest({
    required this.fromAccountNumber,
    required this.toAccountNumber,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromAccountNumber': fromAccountNumber,
      'toAccountNumber': toAccountNumber,
      'amount': amount,
    };
  }

  @override
  String toString() {
    return 'TransferRequest(fromAccountNumber: $fromAccountNumber, toAccountNumber: $toAccountNumber, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransferRequest &&
        other.fromAccountNumber == fromAccountNumber &&
        other.toAccountNumber == toAccountNumber &&
        other.amount == amount;
  }

  @override
  int get hashCode {
    return Object.hash(fromAccountNumber, toAccountNumber, amount);
  }
}

class TransferResponse {
  final String transactionId;
  final String fromAccountNumber;
  final String toAccountNumber;
  final double amount;
  final DateTime timestamp;
  final String status;
  final String? message;

  const TransferResponse({
    required this.transactionId,
    required this.fromAccountNumber,
    required this.toAccountNumber,
    required this.amount,
    required this.timestamp,
    required this.status,
    this.message,
  });

  factory TransferResponse.fromJson(Map<String, dynamic> json) {
    return TransferResponse(
      transactionId: json['transactionId'] as String,
      fromAccountNumber: json['fromAccountNumber'] as String,
      toAccountNumber: json['toAccountNumber'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'fromAccountNumber': fromAccountNumber,
      'toAccountNumber': toAccountNumber,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'TransferResponse(transactionId: $transactionId, fromAccountNumber: $fromAccountNumber, toAccountNumber: $toAccountNumber, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransferResponse &&
        other.transactionId == transactionId &&
        other.fromAccountNumber == fromAccountNumber &&
        other.toAccountNumber == toAccountNumber &&
        other.amount == amount &&
        other.timestamp == timestamp &&
        other.status == status &&
        other.message == message;
  }

  @override
  int get hashCode {
    return Object.hash(
      transactionId,
      fromAccountNumber,
      toAccountNumber,
      amount,
      timestamp,
      status,
      message,
    );
  }

  // Helper getters
  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
  bool get isSuccessful =>
      status.toLowerCase() == 'success' || status.toLowerCase() == 'completed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isFailed =>
      status.toLowerCase() == 'failed' || status.toLowerCase() == 'error';
}
