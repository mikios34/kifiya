import 'package:equatable/equatable.dart';
import 'package:kifiya/features/account/data/model/account_model.dart';
import 'package:kifiya/features/account/data/repository/account_repository.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {
  const AccountInitial();
}

class AccountLoading extends AccountState {
  const AccountLoading();
}

class AccountLoaded extends AccountState {
  final List<AccountModel> accounts;
  final AccountModel? selectedAccount;

  const AccountLoaded({required this.accounts, this.selectedAccount});

  @override
  List<Object?> get props => [accounts, selectedAccount];

  AccountLoaded copyWith({
    List<AccountModel>? accounts,
    AccountModel? selectedAccount,
    bool clearSelectedAccount = false,
  }) {
    return AccountLoaded(
      accounts: accounts ?? this.accounts,
      selectedAccount: clearSelectedAccount
          ? null
          : selectedAccount ?? this.selectedAccount,
    );
  }

  // Helper getters
  double get totalBalance =>
      accounts.fold(0.0, (sum, account) => sum + account.balance);

  List<AccountModel> get checkingAccounts => accounts
      .where((account) => account.accountType == AccountType.checking)
      .toList();

  List<AccountModel> get savingsAccounts => accounts
      .where((account) => account.accountType == AccountType.savings)
      .toList();

  AccountModel? get primaryAccount =>
      accounts.isNotEmpty ? accounts.first : null;
}

class AccountSingleLoaded extends AccountState {
  final AccountModel account;

  const AccountSingleLoaded(this.account);

  @override
  List<Object> get props => [account];
}

class AccountCreated extends AccountState {
  final AccountModel account;

  const AccountCreated(this.account);

  @override
  List<Object> get props => [account];
}

class AccountError extends AccountState {
  final AccountFailure failure;
  final List<AccountModel>? currentAccounts;

  const AccountError(this.failure, {this.currentAccounts});

  @override
  List<Object?> get props => [failure, currentAccounts];

  String get errorMessage {
    return failure.toString();
  }
}

class AccountEmpty extends AccountState {
  const AccountEmpty();
}
