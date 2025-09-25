import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kifiya/core/theme/app_theme.dart';
import 'package:kifiya/core/assets/app_icons.dart';
import 'package:kifiya/features/account/data/model/account_model.dart';
import 'package:kifiya/features/account/presentation/pages/accounts_page.dart';
import 'package:kifiya/features/account/presentation/bloc/bloc.dart';
import 'package:kifiya/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kifiya/features/auth/presentation/bloc/auth_state.dart';
import 'package:kifiya/features/home/presentation/pages/transfer_page.dart';
import 'package:kifiya/features/transaction/presentation/pages/transactions_page.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/homePage';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColorAuth,
      body: SafeArea(
        child: SingleChildScrollView(
          // padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),

                    // Balance Card
                    _buildBalanceCard(),
                    // const SizedBox(height: 30),
                  ],
                ),
              ),

              // Header Section
              // _buildHeader(),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  children: [
                    _buildActionButtons(context),
                    const SizedBox(height: 30),

                    // My Accounts Section
                    _buildMyAccountsSection(context),
                    const SizedBox(height: 30),

                    // Recent Transactions Section
                    _buildRecentTransactionsSection(context),
                  ],
                ),
              ),

              // Action Buttons
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning!',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return Text(
                    state.username,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange[300],
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 28),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'ETB 8,640.00',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Available Balance',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.swap_horiz,
          label: 'Transfer',
          onTap: () {
            context.pushNamed(TransferPage.routeName);
          },
        ),
        _buildActionButton(icon: Icons.document_scanner, label: 'Bills'),
        _buildActionButton(icon: Icons.phone_iphone, label: 'Recharge'),
        _buildActionButton(icon: Icons.more_horiz, label: 'More'),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.indigo[50],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, size: 28, color: AppTheme.textColorDark),
            iconSize: 28,
            color: AppTheme.textColorDark,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildMyAccountsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Accounts',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                context.go(AccountsPage.routeName);
              },
              child: Text(
                'View All',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            // Load accounts when the widget is built if not already loaded
            if (state is AccountInitial) {
              context.read<AccountBloc>().add(const AccountLoadRequested());
              return _buildLoadingContainer();
            }

            if (state is AccountLoading) {
              return _buildLoadingContainer();
            }

            if (state is AccountError) {
              return _buildErrorContainer(state.errorMessage);
            }

            if (state is AccountEmpty) {
              return _buildEmptyContainer();
            }

            if (state is AccountLoaded) {
              return _buildAccountsContainer(state.accounts);
            }

            return _buildLoadingContainer();
          },
        ),
      ],
    );
  }

  Widget _buildLoadingContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildErrorContainer(String errorMessage) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              'Error loading accounts',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<AccountBloc>().add(const AccountLoadRequested());
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.grey,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No accounts found',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first account to get started',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsContainer(List<AccountModel> accounts) {
    // Take only the first 2 accounts for the home page preview
    final displayAccounts = accounts.take(2).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: displayAccounts.asMap().entries.map((entry) {
          int index = entry.key;
          AccountModel account = entry.value;
          bool isFirst = index == 0;
          bool isLast = index == displayAccounts.length - 1;

          return Column(
            children: [
              _buildAccountItem(
                account: account,
                icon: _getAccountIcon(account.accountType),
                title: account.accountType.displayName,
                subtitle: '(${account.maskedAccountNumber})',
                amount: account.formattedBalance,
                lastUpdated: 'Account #${account.id}',
                isFirst: isFirst,
              ),
              if (!isLast) Container(height: 1, color: Colors.black26),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getAccountIcon(AccountType accountType) {
    switch (accountType) {
      case AccountType.savings:
        return AppIcons.savingIcon;
      case AccountType.checking:
        return AppIcons.checkingIcon;
      case AccountType.business:
        return AppIcons.cardsIcon; // Use cards icon for business
      case AccountType.investment:
        return AppIcons.otherIcon; // Use other icon for investment
    }
  }

  Widget _buildAccountItem({
    required AccountModel account,
    required String icon,
    required String title,
    required String subtitle,
    required String amount,
    required String lastUpdated,
    required bool isFirst,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to transactions page with account ID
        context.go('${TransactionsPage.routeName}?accountId=${account.id}');
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 1),
              ),
              child: Image.asset(icon, height: 20, width: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lastUpdated,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                context.go(TransactionsPage.routeName);
              },
              child: Text(
                'View All',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey, width: 1),

            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 2,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildTransactionItem(
                icon: Icons.shopping_cart,
                title: 'Grocery',
                amount: '-\$400',
                isExpense: true,
              ),
              Container(
                height: 1,
                // margin: const EdgeInsets.only(left: 80),
                color: Colors.black26,
              ),
              _buildTransactionItem(
                icon: Icons.receipt,
                title: 'IESCO Bill',
                amount: '-\$120',
                isExpense: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String amount,
    required bool isExpense,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey, width: 1),
            ),
            child: Icon(icon),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
