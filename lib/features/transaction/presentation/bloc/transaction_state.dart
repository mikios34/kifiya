import 'package:equatable/equatable.dart';
import 'package:kifiya/features/transaction/data/model/transaction_model.dart';
import 'package:kifiya/features/transaction/data/repository/transaction_repository.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionLoadingMore extends TransactionState {
  final List<TransactionModel> currentTransactions;
  final int currentPage;
  final bool hasMore;

  const TransactionLoadingMore({
    required this.currentTransactions,
    required this.currentPage,
    required this.hasMore,
  });

  @override
  List<Object> get props => [currentTransactions, currentPage, hasMore];
}

class TransactionRefreshing extends TransactionState {
  final List<TransactionModel> currentTransactions;

  const TransactionRefreshing(this.currentTransactions);

  @override
  List<Object> get props => [currentTransactions];
}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final bool hasMore;
  final TransactionDirection? currentFilter;

  const TransactionLoaded({
    required this.transactions,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
    required this.hasMore,
    this.currentFilter,
  });

  @override
  List<Object?> get props => [
    transactions,
    currentPage,
    totalPages,
    totalElements,
    hasMore,
    currentFilter,
  ];

  TransactionLoaded copyWith({
    List<TransactionModel>? transactions,
    int? currentPage,
    int? totalPages,
    int? totalElements,
    bool? hasMore,
    TransactionDirection? currentFilter,
    bool clearFilter = false,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      hasMore: hasMore ?? this.hasMore,
      currentFilter: clearFilter ? null : currentFilter ?? this.currentFilter,
    );
  }

  // Helper getters
  List<TransactionModel> get todayTransactions {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return transactions
        .where(
          (transaction) =>
              transaction.timestamp.isAfter(todayStart) &&
              transaction.timestamp.isBefore(todayEnd),
        )
        .toList();
  }

  List<TransactionModel> get yesterdayTransactions {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayStart = DateTime(
      yesterday.year,
      yesterday.month,
      yesterday.day,
    );
    final yesterdayEnd = yesterdayStart.add(const Duration(days: 1));

    return transactions
        .where(
          (transaction) =>
              transaction.timestamp.isAfter(yesterdayStart) &&
              transaction.timestamp.isBefore(yesterdayEnd),
        )
        .toList();
  }

  List<TransactionModel> get olderTransactions {
    final today = DateTime.now();
    final twoDaysAgo = today.subtract(const Duration(days: 2));
    final twoDaysAgoStart = DateTime(
      twoDaysAgo.year,
      twoDaysAgo.month,
      twoDaysAgo.day,
    );

    return transactions
        .where((transaction) => transaction.timestamp.isBefore(twoDaysAgoStart))
        .toList();
  }

  double get totalIncome {
    return transactions
        .where((transaction) => transaction.direction.isIncome)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get totalExpense {
    return transactions
        .where((transaction) => transaction.direction.isExpense)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }
}

class TransactionEmpty extends TransactionState {
  final TransactionDirection? currentFilter;

  const TransactionEmpty({this.currentFilter});

  @override
  List<Object?> get props => [currentFilter];
}

class TransactionError extends TransactionState {
  final TransactionFailure failure;
  final List<TransactionModel>? currentTransactions;

  const TransactionError(this.failure, {this.currentTransactions});

  @override
  List<Object?> get props => [failure, currentTransactions];

  String get errorMessage {
    return failure.toString();
  }
}

class TransactionDetailsLoaded extends TransactionState {
  final TransactionModel transaction;

  const TransactionDetailsLoaded(this.transaction);

  @override
  List<Object> get props => [transaction];
}
