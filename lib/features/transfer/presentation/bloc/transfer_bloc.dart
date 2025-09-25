import 'package:bloc/bloc.dart';
import 'package:kifiya/features/transfer/data/repository/transfer_repository.dart';
import 'package:kifiya/features/transfer/presentation/bloc/transfer_event.dart';
import 'package:kifiya/features/transfer/presentation/bloc/transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final TransferRepository _transferRepository;

  TransferBloc(this._transferRepository) : super(const TransferInitial()) {
    on<TransferRequested>(_onTransferRequested);
    on<TransferHistoryRequested>(_onTransferHistoryRequested);
    on<TransferByIdRequested>(_onTransferByIdRequested);
    on<TransferClearError>(_onTransferClearError);
    on<TransferReset>(_onTransferReset);
  }

  Future<void> _onTransferRequested(
    TransferRequested event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());

    final result = await _transferRepository.transfer(event.request);

    result.fold(
      (failure) => emit(TransferError(failure)),
      (response) => emit(TransferSuccess(response)),
    );
  }

  Future<void> _onTransferHistoryRequested(
    TransferHistoryRequested event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());

    final result = await _transferRepository.getTransferHistory();

    result.fold(
      (failure) => emit(TransferError(failure)),
      (transfers) => emit(TransferHistoryLoaded(transfers)),
    );
  }

  Future<void> _onTransferByIdRequested(
    TransferByIdRequested event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());

    final result = await _transferRepository.getTransferById(
      event.transactionId,
    );

    result.fold(
      (failure) => emit(TransferError(failure)),
      (transfer) => emit(TransferDetailsLoaded(transfer)),
    );
  }

  void _onTransferClearError(
    TransferClearError event,
    Emitter<TransferState> emit,
  ) {
    emit(const TransferInitial());
  }

  void _onTransferReset(TransferReset event, Emitter<TransferState> emit) {
    emit(const TransferInitial());
  }
}
