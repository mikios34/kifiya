enum TransactionType {
  fundTransfer,
  billPayment,
  deposit,
  withdrawal,
  salary,
  shopping,
  other;

  static TransactionType fromString(String type) {
    switch (type.toUpperCase()) {
      case 'FUND_TRANSFER':
        return TransactionType.fundTransfer;
      case 'BILL_PAYMENT':
        return TransactionType.billPayment;
      case 'DEPOSIT':
        return TransactionType.deposit;
      case 'WITHDRAWAL':
        return TransactionType.withdrawal;
      case 'SALARY':
        return TransactionType.salary;
      case 'SHOPPING':
        return TransactionType.shopping;
      default:
        return TransactionType.other;
    }
  }

  String get displayName {
    switch (this) {
      case TransactionType.fundTransfer:
        return 'Fund Transfer';
      case TransactionType.billPayment:
        return 'Bill Payment';
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.salary:
        return 'Salary';
      case TransactionType.shopping:
        return 'Shopping';
      case TransactionType.other:
        return 'Other';
    }
  }
}

enum TransactionDirection {
  debit,
  credit;

  static TransactionDirection fromString(String direction) {
    switch (direction.toUpperCase()) {
      case 'DEBIT':
        return TransactionDirection.debit;
      case 'CREDIT':
        return TransactionDirection.credit;
      default:
        return TransactionDirection.debit;
    }
  }

  String get displayName {
    switch (this) {
      case TransactionDirection.debit:
        return 'Expense';
      case TransactionDirection.credit:
        return 'Income';
    }
  }

  bool get isExpense => this == TransactionDirection.debit;
  bool get isIncome => this == TransactionDirection.credit;
}

class TransactionModel {
  final int id;
  final double amount;
  final TransactionType type;
  final TransactionDirection direction;
  final DateTime timestamp;
  final String description;
  final String? relatedAccount;
  final int accountId;

  const TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.direction,
    required this.timestamp,
    required this.description,
    this.relatedAccount,
    required this.accountId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.fromString(json['type'] as String),
      direction: TransactionDirection.fromString(json['direction'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String,
      relatedAccount: json['relatedAccount'] as String?,
      accountId: json['accountId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name.toUpperCase(),
      'direction': direction.name.toUpperCase(),
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'relatedAccount': relatedAccount,
      'accountId': accountId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel &&
        other.id == id &&
        other.amount == amount &&
        other.type == type &&
        other.direction == direction &&
        other.timestamp == timestamp &&
        other.description == description &&
        other.relatedAccount == relatedAccount &&
        other.accountId == accountId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      amount,
      type,
      direction,
      timestamp,
      description,
      relatedAccount,
      accountId,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, amount: $amount, type: $type, direction: $direction, description: $description)';
  }

  // Helper getters
  String get formattedAmount {
    final sign = direction.isExpense ? '-' : '+';
    return '$sign\$${amount.toStringAsFixed(2)}';
  }

  String get formattedTimestamp {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (transactionDate == today) {
      return 'Today ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (transactionDate == yesterday) {
      return 'Yesterday ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String get shortDescription {
    if (description.length <= 30) return description;
    return '${description.substring(0, 30)}...';
  }

  String get iconPath {
    switch (type) {
      case TransactionType.fundTransfer:
        return 'assets/icons/transfer.png';
      case TransactionType.billPayment:
        return 'assets/icons/bill.png';
      case TransactionType.salary:
        return 'assets/icons/salary.png';
      case TransactionType.shopping:
        return 'assets/icons/shopping.png';
      default:
        return 'assets/icons/other.png';
    }
  }
}

class TransactionSort {
  final String property;
  final String direction;
  final bool ascending;
  final String nullHandling;
  final bool ignoreCase;

  const TransactionSort({
    required this.property,
    required this.direction,
    required this.ascending,
    required this.nullHandling,
    required this.ignoreCase,
  });

  factory TransactionSort.fromJson(Map<String, dynamic> json) {
    return TransactionSort(
      property: json['property'] as String? ?? '',
      direction: json['direction'] as String? ?? 'ASC',
      ascending: json['ascending'] as bool? ?? true,
      nullHandling: json['nullHandling'] as String? ?? 'NATIVE',
      ignoreCase: json['ignoreCase'] as bool? ?? false,
    );
  }
}

class TransactionPageable {
  final bool paged;
  final int pageNumber;
  final int pageSize;
  final int offset;
  final List<TransactionSort> sort;
  final bool unpaged;

  const TransactionPageable({
    required this.paged,
    required this.pageNumber,
    required this.pageSize,
    required this.offset,
    required this.sort,
    required this.unpaged,
  });

  factory TransactionPageable.fromJson(Map<String, dynamic> json) {
    return TransactionPageable(
      paged: json['paged'] as bool,
      pageNumber: json['pageNumber'] as int,
      pageSize: json['pageSize'] as int,
      offset: json['offset'] as int,
      sort: _parseSortFromJson(json['sort']),
      unpaged: json['unpaged'] as bool,
    );
  }

  // Helper method to parse sort field which can be either List or single object
  static List<TransactionSort> _parseSortFromJson(dynamic sortJson) {
    if (sortJson == null) return [];

    if (sortJson is List) {
      return sortJson
          .map((item) => TransactionSort.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (sortJson is Map<String, dynamic>) {
      // Check if it's a valid TransactionSort object or just pagination metadata
      if (sortJson.containsKey('direction') &&
          sortJson.containsKey('property')) {
        return [TransactionSort.fromJson(sortJson)];
      } else {
        // It's probably pagination metadata like {"sorted": false, "empty": true, "unsorted": true}
        // Return empty list for this case
        return [];
      }
    }

    return [];
  }
}

class TransactionPageResponse {
  final int totalPages;
  final int totalElements;
  final TransactionPageable pageable;
  final int size;
  final List<TransactionModel> content;
  final int number;
  final List<TransactionSort> sort;
  final bool first;
  final bool last;
  final int numberOfElements;
  final bool empty;

  const TransactionPageResponse({
    required this.totalPages,
    required this.totalElements,
    required this.pageable,
    required this.size,
    required this.content,
    required this.number,
    required this.sort,
    required this.first,
    required this.last,
    required this.numberOfElements,
    required this.empty,
  });

  factory TransactionPageResponse.fromJson(Map<String, dynamic> json) {
    return TransactionPageResponse(
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
      pageable: TransactionPageable.fromJson(
        json['pageable'] as Map<String, dynamic>,
      ),
      size: json['size'] as int,
      content:
          (json['content'] as List<dynamic>?)
              ?.map(
                (item) =>
                    TransactionModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      number: json['number'] as int,
      sort: TransactionPageable._parseSortFromJson(json['sort']),
      first: json['first'] as bool,
      last: json['last'] as bool,
      numberOfElements: json['numberOfElements'] as int,
      empty: json['empty'] as bool,
    );
  }

  @override
  String toString() {
    return 'TransactionPageResponse(totalElements: $totalElements, totalPages: $totalPages, number: $number, content: ${content.length} items)';
  }
}
