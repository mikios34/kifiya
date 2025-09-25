import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kifiya/core/theme/app_theme.dart';
import 'package:kifiya/features/account/data/model/account_model.dart';
import 'package:kifiya/features/account/presentation/bloc/bloc.dart';
import 'package:kifiya/features/transfer/data/model/transfer_model.dart';
import 'package:kifiya/features/transfer/presentation/bloc/bloc.dart';

class TransferPage extends StatefulWidget {
  static const String routeName = 'transferPage';
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _toAccountController = TextEditingController();
  final PageController _pageController = PageController();
  String selectedPurpose = 'Education';
  int selectedContactIndex = -1;
  int _currentAccountIndex = 0;
  AccountModel? _selectedFromAccount;

  final List<Contact> contacts = [
    Contact(name: 'Aliya', avatar: ''),
    Contact(name: 'Calira', avatar: ''),
    Contact(name: 'Bob', avatar: ''),
    Contact(name: 'Samy', avatar: ''),
    Contact(name: 'Sara', avatar: ''),
  ];

  final List<String> purposes = [
    'Education',
    'Food',
    'Transportation',
    'Entertainment',
    'Shopping',
    'Bills',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _amountController.text = '0.00';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _toAccountController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),

                      // From Section
                      _buildFromSection(),

                      const SizedBox(height: 20),

                      // Card Indicators
                      _buildCardIndicators(),

                      const SizedBox(height: 40),

                      // To Section
                      _buildToSection(),

                      const SizedBox(height: 40),

                      // Amount Section
                      _buildAmountSection(),

                      const SizedBox(height: 40),

                      // Purpose Section
                      _buildPurposeSection(),

                      const SizedBox(height: 50),

                      // Send Button
                      _buildSendButton(),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Transfer',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 36), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildFromSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'From',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            // Load accounts when the widget is built if not already loaded
            if (state is AccountInitial) {
              context.read<AccountBloc>().add(const AccountLoadRequested());
              return _buildLoadingCard();
            }

            if (state is AccountLoading) {
              return _buildLoadingCard();
            }

            if (state is AccountError) {
              return _buildErrorCard(state.errorMessage);
            }

            if (state is AccountEmpty) {
              return _buildEmptyCard();
            }

            if (state is AccountLoaded) {
              return _buildAccountCarousel(state.accounts);
            }

            return _buildLoadingCard();
          },
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.gradientColor1, AppTheme.gradientColor2],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String errorMessage) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.red[50],
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 24),
            const SizedBox(height: 8),
            Text(
              'Error loading accounts',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: () {
                context.read<AccountBloc>().add(const AccountLoadRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(80, 30),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No accounts found',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCarousel(List<AccountModel> accounts) {
    // Set the first account as default if no account is selected
    if (_selectedFromAccount == null && accounts.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedFromAccount = accounts[0];
          _currentAccountIndex = 0;
        });
      });
    }

    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentAccountIndex = index;
            _selectedFromAccount = accounts[index];
          });
        },
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final account = accounts[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildAccountCard(account),
          );
        },
      ),
    );
  }

  Widget _buildAccountCard(AccountModel account) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getCardGradient(account.accountType),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                account.accountType.displayName,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              Text(
                account.formattedBalance,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            account.maskedAccountNumber,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getCardGradient(AccountType accountType) {
    switch (accountType) {
      case AccountType.savings:
        return [AppTheme.gradientColor1, AppTheme.gradientColor2];
      case AccountType.checking:
        return [const Color(0xFF667eea), const Color(0xFF764ba2)];
      case AccountType.business:
        return [const Color(0xFF11998e), const Color(0xFF38ef7d)];
      case AccountType.investment:
        return [const Color(0xFFfc466b), const Color(0xFF3f5efb)];
      default:
        return [AppTheme.gradientColor1, AppTheme.gradientColor2];
    }
  }

  Widget _buildCardIndicators() {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        if (state is AccountLoaded) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              state.accounts.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == _currentAccountIndex
                      ? const Color(0xFF6B73FF)
                      : Colors.grey[400],
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }

        // Default indicators for loading/error states
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF6B73FF),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'To',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _toAccountController,
          keyboardType: TextInputType.number,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: 'Enter destination account number',
            hintStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.grey[500],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6B73FF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            prefixIcon: const Icon(
              Icons.account_balance,
              color: Color(0xFF6B73FF),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Quick Transfer to Contacts',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 85,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: contacts.length + 1, // +1 for add button
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildAddContactButton();
              }
              return _buildContactAvatar(contacts[index - 1], index - 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddContactButton() {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF6B73FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Color(0xFF6B73FF), size: 24),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildContactAvatar(Contact contact, int index) {
    Color avatarColor = _getAvatarColor(index);
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedContactIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: selectedContactIndex == index
                    ? Border.all(color: const Color(0xFF6B73FF), width: 2)
                    : null,
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: avatarColor,
                child: Text(
                  contact.name[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              contact.name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(int index) {
    List<Color> colors = [
      const Color(0xFF6B73FF),
      const Color(0xFF50C878),
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFBE0B),
    ];
    return colors[index % colors.length];
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black45,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            prefix: Text(
              '\$',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6B73FF)),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildPurposeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Purpose',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: selectedPurpose,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6B73FF)),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: purposes.map((String purpose) {
            return DropdownMenuItem<String>(
              value: purpose,
              child: Text(
                purpose,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedPurpose = newValue;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    return BlocConsumer<TransferBloc, TransferState>(
      listener: (context, state) {
        if (state is TransferSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage),
              backgroundColor: Colors.green,
            ),
          );
          // Reset form
          _amountController.text = '0.00';
          _toAccountController.clear();
          context.read<TransferBloc>().add(const TransferReset());
        } else if (state is TransferError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state is TransferLoading ? null : _handleTransfer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A5568),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: state is TransferLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Send',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _handleTransfer() {
    // Validate inputs
    if (_selectedFromAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a source account'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_toAccountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter destination account number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty || amountText == '0.00') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if sufficient balance
    if (amount > _selectedFromAccount!.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient balance'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create transfer request
    final transferRequest = TransferRequest(
      fromAccountNumber: _selectedFromAccount!.accountNumber,
      toAccountNumber: _toAccountController.text.trim(),
      amount: amount,
    );

    // Send transfer request
    context.read<TransferBloc>().add(TransferRequested(transferRequest));
  }
}

class Contact {
  final String name;
  final String avatar;

  Contact({required this.name, required this.avatar});
}
