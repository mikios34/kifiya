import 'package:equatable/equatable.dart';
import 'package:kifiya/features/transfer/data/model/transfer_model.dart';
import 'package:kifiya/features/transfer/data/repository/transfer_repository.dart';

abstract class TransferState extends Equatable {
  const TransferState();

  @override
  List<Object?> get props => [];
}

class TransferInitial extends TransferState {
  const TransferInitial();
}

class TransferLoading extends TransferState {
  const TransferLoading();
}

class TransferSuccess extends TransferState {
  final TransferResponse response;

  const TransferSuccess(this.response);

  @override
  List<Object> get props => [response];

  String get successMessage {
    return 'Transfer of ${response.formattedAmount} completed successfully!';
  }
}

class TransferError extends TransferState {
  final TransferFailure failure;

  const TransferError(this.failure);

  @override
  List<Object> get props => [failure];

  String get errorMessage {
    return failure.toString();
  }
}

class TransferHistoryLoaded extends TransferState {
  final List<TransferResponse> transfers;

  const TransferHistoryLoaded(this.transfers);

  @override
  List<Object> get props => [transfers];
}

class TransferDetailsLoaded extends TransferState {
  final TransferResponse transfer;

  const TransferDetailsLoaded(this.transfer);

  @override
  List<Object> get props => [transfer];
}
