import 'package:bloc/bloc.dart';
import 'package:kifiya/features/transaction/data/repository/transaction_repository.dart';
import 'package:kifiya/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:kifiya/features/transaction/presentation/bloc/transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _transactionRepository;

  TransactionBloc(this._transactionRepository)
    : super(const TransactionInitial()) {
    on<TransactionLoadRequested>(_onTransactionLoadRequested);
    on<TransactionLoadMoreRequested>(_onTransactionLoadMoreRequested);
    on<TransactionRefreshRequested>(_onTransactionRefreshRequested);
    on<TransactionFilterChanged>(_onTransactionFilterChanged);
    on<TransactionByIdRequested>(_onTransactionByIdRequested);
    on<TransactionDetailsRequested>(_onTransactionDetailsRequested);
    on<TransactionClearError>(_onTransactionClearError);
    on<TransactionReset>(_onTransactionReset);
  }

  Future<void> _onTransactionLoadRequested(
    TransactionLoadRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());

    final result = await _transactionRepository.getTransactionsByAccountId(
      accountId: event.accountId,
      page: event.page,
      size: event.size,
      sortBy: event.sortBy,
      sortDirection: event.sortDirection,
    );

    result.fold((failure) => emit(TransactionError(failure)), (response) {
      if (response.content.isEmpty) {
        emit(const TransactionEmpty());
      } else {
        emit(
          TransactionLoaded(
            transactions: response.content,
            currentPage: response.number,
            totalPages: response.totalPages,
            totalElements: response.totalElements,
            hasMore: !response.last,
          ),
        );
      }
    });
  }

  Future<void> _onTransactionLoadMoreRequested(
    TransactionLoadMoreRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TransactionLoaded || !currentState.hasMore) {
      return;
    }

    emit(
      TransactionLoadingMore(
        currentTransactions: currentState.transactions,
        currentPage: currentState.currentPage,
        hasMore: currentState.hasMore,
      ),
    );

    final result = await _transactionRepository.getTransactionsByAccountId(
      accountId: event.accountId,
      page: event.page,
      size: event.size,
      sortBy: event.sortBy,
      sortDirection: event.sortDirection,
    );

    result.fold(
      (failure) => emit(
        TransactionError(
          failure,
          currentTransactions: currentState.transactions,
        ),
      ),
      (response) {
        final allTransactions = [
          ...currentState.transactions,
          ...response.content,
        ];

        emit(
          TransactionLoaded(
            transactions: allTransactions,
            currentPage: response.number,
            totalPages: response.totalPages,
            totalElements: response.totalElements,
            hasMore: !response.last,
            currentFilter: currentState.currentFilter,
          ),
        );
      },
    );
  }

  Future<void> _onTransactionRefreshRequested(
    TransactionRefreshRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final currentState = state;

    if (currentState is TransactionLoaded) {
      emit(TransactionRefreshing(currentState.transactions));
    } else {
      emit(const TransactionLoading());
    }

    final result = await _transactionRepository.getTransactionsByAccountId(
      accountId: event.accountId,
      page: 0,
      size: event.size,
      sortBy: event.sortBy,
      sortDirection: event.sortDirection,
    );

    result.fold(
      (failure) {
        if (currentState is TransactionLoaded) {
          emit(
            TransactionError(
              failure,
              currentTransactions: currentState.transactions,
            ),
          );
        } else {
          emit(TransactionError(failure));
        }
      },
      (response) {
        if (response.content.isEmpty) {
          emit(const TransactionEmpty());
        } else {
          emit(
            TransactionLoaded(
              transactions: response.content,
              currentPage: response.number,
              totalPages: response.totalPages,
              totalElements: response.totalElements,
              hasMore: !response.last,
              currentFilter: currentState is TransactionLoaded
                  ? currentState.currentFilter
                  : null,
            ),
          );
        }
      },
    );
  }

  Future<void> _onTransactionFilterChanged(
    TransactionFilterChanged event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());

    late final result;

    if (event.direction != null) {
      result = await _transactionRepository.getTransactionsByType(
        accountId: event.accountId,
        direction: event.direction!,
        page: 0,
        size: event.size,
        sortBy: event.sortBy,
        sortDirection: event.sortDirection,
      );
    } else {
      result = await _transactionRepository.getTransactionsByAccountId(
        accountId: event.accountId,
        page: 0,
        size: event.size,
        sortBy: event.sortBy,
        sortDirection: event.sortDirection,
      );
    }

    result.fold((failure) => emit(TransactionError(failure)), (response) {
      if (response.content.isEmpty) {
        emit(TransactionEmpty(currentFilter: event.direction));
      } else {
        emit(
          TransactionLoaded(
            transactions: response.content,
            currentPage: response.number,
            totalPages: response.totalPages,
            totalElements: response.totalElements,
            hasMore: !response.last,
            currentFilter: event.direction,
          ),
        );
      }
    });
  }

  Future<void> _onTransactionByIdRequested(
    TransactionByIdRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());

    final result = await _transactionRepository.getTransactionById(
      event.transactionId,
    );

    result.fold(
      (failure) => emit(TransactionError(failure)),
      (transaction) => emit(TransactionDetailsLoaded(transaction)),
    );
  }

  void _onTransactionDetailsRequested(
    TransactionDetailsRequested event,
    Emitter<TransactionState> emit,
  ) {
    emit(TransactionDetailsLoaded(event.transaction));
  }

  void _onTransactionClearError(
    TransactionClearError event,
    Emitter<TransactionState> emit,
  ) {
    final currentState = state;
    if (currentState is TransactionError &&
        currentState.currentTransactions != null) {
      emit(
        TransactionLoaded(
          transactions: currentState.currentTransactions!,
          currentPage: 0,
          totalPages: 1,
          totalElements: currentState.currentTransactions!.length,
          hasMore: false,
        ),
      );
    } else {
      emit(const TransactionInitial());
    }
  }

  void _onTransactionReset(
    TransactionReset event,
    Emitter<TransactionState> emit,
  ) {
    emit(const TransactionInitial());
  }
}
