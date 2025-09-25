import 'package:equatable/equatable.dart';
import 'package:kifiya/features/account/data/model/account_model.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class AccountLoadRequested extends AccountEvent {
  const AccountLoadRequested();
}

class AccountLoadByIdRequested extends AccountEvent {
  final int accountId;

  const AccountLoadByIdRequested(this.accountId);

  @override
  List<Object> get props => [accountId];
}

class AccountCreateRequested extends AccountEvent {
  final CreateAccountRequest request;

  const AccountCreateRequested(this.request);

  @override
  List<Object> get props => [request];
}

class AccountClearError extends AccountEvent {
  const AccountClearError();
}

class AccountSelectRequested extends AccountEvent {
  final AccountModel account;

  const AccountSelectRequested(this.account);

  @override
  List<Object> get props => [account];
}
