import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kifiya/core/assets/app_icons.dart';
import 'package:kifiya/core/theme/app_theme.dart';
import 'package:kifiya/core/widgets/circular_icon_container.dart';
import 'package:kifiya/core/widgets/grey_border_container.dart';
import 'package:kifiya/features/transaction/data/model/transaction_model.dart';
import 'package:kifiya/features/transaction/presentation/bloc/bloc.dart';

class TransactionsPage extends StatefulWidget {
  static const String routeName = '/transactionsPage';
  final int? accountId;

  const TransactionsPage({super.key, this.accountId});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late final ScrollController _scrollController;
  TransactionDirection? _selectedFilter;
  int _currentPage = 0;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Load transactions if accountId is provided
    if (widget.accountId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TransactionBloc>().add(
          TransactionLoadRequested(
            accountId: widget.accountId!,
            size: _pageSize,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final currentState = context.read<TransactionBloc>().state;
      if (currentState is TransactionLoaded && currentState.hasMore) {
        _loadMoreTransactions();
      }
    }
  }

  void _loadMoreTransactions() {
    if (widget.accountId != null) {
      context.read<TransactionBloc>().add(
        TransactionLoadMoreRequested(
          accountId: widget.accountId!,
          page: _currentPage + 1,
          size: _pageSize,
        ),
      );
      _currentPage++;
    }
  }

  void _refreshTransactions() {
    if (widget.accountId != null) {
      _currentPage = 0;
      context.read<TransactionBloc>().add(
        TransactionRefreshRequested(
          accountId: widget.accountId!,
          size: _pageSize,
        ),
      );
    }
  }

  void _filterTransactions(TransactionDirection? direction) {
    if (widget.accountId != null) {
      setState(() {
        _selectedFilter = direction;
        _currentPage = 0;
      });

      context.read<TransactionBloc>().add(
        TransactionFilterChanged(
          accountId: widget.accountId!,
          direction: direction,
          size: _pageSize,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.accountId == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No Account Selected',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please select an account to view transactions',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'Transactions',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),

            Expanded(
              child: BlocConsumer<TransactionBloc, TransactionState>(
                listener: (context, state) {
                  if (state is TransactionError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage),
                        backgroundColor: Colors.red,
                        action: SnackBarAction(
                          label: 'Retry',
                          textColor: Colors.white,
                          onPressed: _refreshTransactions,
                        ),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return RefreshIndicator(
                    onRefresh: () async => _refreshTransactions(),
                    child: _buildContent(state),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(TransactionState state) {
    if (state is TransactionLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is TransactionEmpty) {
      return SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              _buildFilterSection(),
              const SizedBox(height: 30),
              _buildTransactionTypeFilters(),
              const SizedBox(height: 100),
              _buildEmptyState(),
            ],
          ),
        ),
      );
    }

    if (state is TransactionError && state.currentTransactions == null) {
      return SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              _buildFilterSection(),
              const SizedBox(height: 30),
              _buildTransactionTypeFilters(),
              const SizedBox(height: 100),
              _buildErrorState(state.errorMessage),
            ],
          ),
        ),
      );
    }

    // Handle loaded state and loading more state
    List<TransactionModel> transactions = [];
    bool isLoadingMore = false;

    if (state is TransactionLoaded) {
      transactions = state.transactions;
    } else if (state is TransactionLoadingMore) {
      transactions = state.currentTransactions;
      isLoadingMore = true;
    } else if (state is TransactionRefreshing) {
      transactions = state.currentTransactions;
    } else if (state is TransactionError && state.currentTransactions != null) {
      transactions = state.currentTransactions!;
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterSection(),
            const SizedBox(height: 30),
            _buildTransactionTypeFilters(),
            const SizedBox(height: 30),
            _buildTransactionsList(transactions),
            if (isLoadingMore) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        GestureDetector(
          onTap: () {
            // Handle time range selection - can be implemented later
          },
          child: Text(
            'Select Time Range',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTypeFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            '  All  ',
            _selectedFilter == null,
            () => _filterTransactions(null),
          ),
          const SizedBox(width: 12),
          _buildFilterChip(
            'Income',
            _selectedFilter == TransactionDirection.credit,
            () => _filterTransactions(TransactionDirection.credit),
            icon: Icons.arrow_downward,
            iconColor: Colors.green,
          ),
          const SizedBox(width: 12),
          _buildFilterChip(
            'Expense',
            _selectedFilter == TransactionDirection.debit,
            () => _filterTransactions(TransactionDirection.debit),
            icon: Icons.arrow_upward,
            iconColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    IconData? icon,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6B73FF).withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: iconColor?.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 12, color: iconColor),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppTheme.textColorDark : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(List<TransactionModel> allTransactions) {
    // Group transactions by date
    final groupedTransactions = _groupTransactionsByDate(allTransactions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedTransactions.entries.map((entry) {
        final dateLabel = entry.key;
        final transactions = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransactionSection(dateLabel, transactions),
            const SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }

  Map<String, List<TransactionModel>> _groupTransactionsByDate(
    List<TransactionModel> transactions,
  ) {
    final Map<String, List<TransactionModel>> grouped = {};

    for (final transaction in transactions) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final transactionDate = DateTime(
        transaction.timestamp.year,
        transaction.timestamp.month,
        transaction.timestamp.day,
      );

      String dateLabel;
      if (transactionDate == today) {
        dateLabel = 'Today';
      } else if (transactionDate == yesterday) {
        dateLabel = 'Yesterday';
      } else {
        dateLabel =
            '${transaction.timestamp.day}/${transaction.timestamp.month}/${transaction.timestamp.year}';
      }

      grouped.putIfAbsent(dateLabel, () => []).add(transaction);
    }

    return grouped;
  }

  Widget _buildTransactionSection(
    String title,
    List<TransactionModel> transactions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        GreyBorderContainer(
          child: Column(
            children: transactions.asMap().entries.map((entry) {
              int index = entry.key;
              TransactionModel transaction = entry.value;
              bool isLast = index == transactions.length - 1;

              return Column(
                children: [
                  _buildTransactionItem(transaction),
                  if (!isLast) const Divider(height: 1, indent: 0),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    return GestureDetector(
      onTap: () => _showTransactionDetails(transaction),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            CircularIconContainer(icon: _getTransactionIcon(transaction.type)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.shortDescription,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.formattedTimestamp,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              transaction.formattedAmount,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: transaction.direction.isExpense
                    ? Colors.red[600]
                    : Colors.green[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.fundTransfer:
        return AppIcons.transferIcon;
      case TransactionType.billPayment:
        return AppIcons.statementIcon;
      case TransactionType.salary:
        return AppIcons.salaryIcon;
      case TransactionType.shopping:
        return AppIcons.shoppingIcon;
      default:
        return AppIcons.cardsIcon;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Transactions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No transactions found for this account',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Error Loading Transactions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _refreshTransactions, child: Text('Retry')),
        ],
      ),
    );
  }

  void _showTransactionDetails(TransactionModel transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildTransactionDetailsBottomSheet(transaction),
    );
  }

  Widget _buildTransactionDetailsBottomSheet(TransactionModel transaction) {
    return Container(
      margin: const EdgeInsets.only(top: 100),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Transaction header
            Row(
              children: [
                CircularIconContainer(
                  icon: _getTransactionIcon(transaction.type),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.type.displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        transaction.direction.displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: transaction.direction.isExpense
                              ? Colors.red[600]
                              : Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  transaction.formattedAmount,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: transaction.direction.isExpense
                        ? Colors.red[600]
                        : Colors.green[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Transaction details
            _buildDetailRow('Transaction ID', transaction.id.toString()),
            _buildDetailRow(
              'Date & Time',
              transaction.timestamp.toString().split('.')[0],
            ),
            _buildDetailRow('Description', transaction.description),
            if (transaction.relatedAccount != null)
              _buildDetailRow('Related Account', transaction.relatedAccount!),
            _buildDetailRow('Account ID', transaction.accountId.toString()),

            const SizedBox(height: 32),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A5568),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
