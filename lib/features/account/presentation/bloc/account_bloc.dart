import 'package:bloc/bloc.dart';
import 'package:kifiya/features/account/data/repository/account_repository.dart';
import 'package:kifiya/features/account/presentation/bloc/account_event.dart';
import 'package:kifiya/features/account/presentation/bloc/account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository _accountRepository;

  AccountBloc(this._accountRepository) : super(const AccountInitial()) {
    on<AccountLoadRequested>(_onAccountLoadRequested);
    on<AccountLoadByIdRequested>(_onAccountLoadByIdRequested);
    on<AccountCreateRequested>(_onAccountCreateRequested);
    on<AccountClearError>(_onAccountClearError);
    on<AccountSelectRequested>(_onAccountSelectRequested);
  }

  Future<void> _onAccountLoadRequested(
    AccountLoadRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountLoading());

    final result = await _accountRepository.getAccounts();

    result.fold((failure) => emit(AccountError(failure)), (accounts) {
      if (accounts.isEmpty) {
        emit(const AccountEmpty());
      } else {
        emit(AccountLoaded(accounts: accounts));
      }
    });
  }

  Future<void> _onAccountLoadByIdRequested(
    AccountLoadByIdRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountLoading());

    final result = await _accountRepository.getAccountById(event.accountId);

    result.fold(
      (failure) => emit(AccountError(failure)),
      (account) => emit(AccountSingleLoaded(account)),
    );
  }

  Future<void> _onAccountCreateRequested(
    AccountCreateRequested event,
    Emitter<AccountState> emit,
  ) async {
    // Keep current state if we have accounts loaded
    final currentState = state;
    if (currentState is AccountLoaded) {
      emit(AccountLoading());
    } else {
      emit(const AccountLoading());
    }

    final result = await _accountRepository.createAccount(event.request);

    result.fold(
      (failure) {
        if (currentState is AccountLoaded) {
          emit(AccountError(failure, currentAccounts: currentState.accounts));
        } else {
          emit(AccountError(failure));
        }
      },
      (account) {
        emit(AccountCreated(account));
        // Automatically reload accounts after creation
        add(const AccountLoadRequested());
      },
    );
  }

  void _onAccountClearError(
    AccountClearError event,
    Emitter<AccountState> emit,
  ) {
    final currentState = state;
    if (currentState is AccountError && currentState.currentAccounts != null) {
      emit(AccountLoaded(accounts: currentState.currentAccounts!));
    } else {
      emit(const AccountInitial());
    }
  }

  void _onAccountSelectRequested(
    AccountSelectRequested event,
    Emitter<AccountState> emit,
  ) {
    final currentState = state;
    if (currentState is AccountLoaded) {
      emit(currentState.copyWith(selectedAccount: event.account));
    }
  }
}
