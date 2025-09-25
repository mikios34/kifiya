import 'package:equatable/equatable.dart';
import 'package:kifiya/features/transfer/data/model/transfer_model.dart';

abstract class TransferEvent extends Equatable {
  const TransferEvent();

  @override
  List<Object> get props => [];
}

class TransferRequested extends TransferEvent {
  final TransferRequest request;

  const TransferRequested(this.request);

  @override
  List<Object> get props => [request];
}

class TransferHistoryRequested extends TransferEvent {
  const TransferHistoryRequested();
}

class TransferByIdRequested extends TransferEvent {
  final String transactionId;

  const TransferByIdRequested(this.transactionId);

  @override
  List<Object> get props => [transactionId];
}

class TransferClearError extends TransferEvent {
  const TransferClearError();
}

class TransferReset extends TransferEvent {
  const TransferReset();
}
