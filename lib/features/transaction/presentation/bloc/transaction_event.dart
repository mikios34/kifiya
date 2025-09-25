import 'package:equatable/equatable.dart';
import 'package:kifiya/features/transaction/data/model/transaction_model.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class TransactionLoadRequested extends TransactionEvent {
  final int accountId;
  final int page;
  final int size;
  final String sortBy;
  final String sortDirection;

  const TransactionLoadRequested({
    required this.accountId,
    this.page = 0,
    this.size = 20,
    this.sortBy = 'timestamp',
    this.sortDirection = 'desc',
  });

  @override
  List<Object> get props => [accountId, page, size, sortBy, sortDirection];
}

class TransactionLoadMoreRequested extends TransactionEvent {
  final int accountId;
  final int page;
  final int size;
  final String sortBy;
  final String sortDirection;

  const TransactionLoadMoreRequested({
    required this.accountId,
    required this.page,
    this.size = 20,
    this.sortBy = 'timestamp',
    this.sortDirection = 'desc',
  });

  @override
  List<Object> get props => [accountId, page, size, sortBy, sortDirection];
}

class TransactionRefreshRequested extends TransactionEvent {
  final int accountId;
  final int size;
  final String sortBy;
  final String sortDirection;

  const TransactionRefreshRequested({
    required this.accountId,
    this.size = 20,
    this.sortBy = 'timestamp',
    this.sortDirection = 'desc',
  });

  @override
  List<Object> get props => [accountId, size, sortBy, sortDirection];
}

class TransactionFilterChanged extends TransactionEvent {
  final int accountId;
  final TransactionDirection? direction;
  final int size;
  final String sortBy;
  final String sortDirection;

  const TransactionFilterChanged({
    required this.accountId,
    this.direction,
    this.size = 20,
    this.sortBy = 'timestamp',
    this.sortDirection = 'desc',
  });

  @override
  List<Object?> get props => [
    accountId,
    direction,
    size,
    sortBy,
    sortDirection,
  ];
}

class TransactionByIdRequested extends TransactionEvent {
  final int transactionId;

  const TransactionByIdRequested(this.transactionId);

  @override
  List<Object> get props => [transactionId];
}

class TransactionDetailsRequested extends TransactionEvent {
  final TransactionModel transaction;

  const TransactionDetailsRequested(this.transaction);

  @override
  List<Object> get props => [transaction];
}

class TransactionClearError extends TransactionEvent {
  const TransactionClearError();
}

class TransactionReset extends TransactionEvent {
  const TransactionReset();
}
