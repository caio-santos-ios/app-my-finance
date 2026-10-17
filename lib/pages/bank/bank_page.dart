import 'package:brasil_fields/brasil_fields.dart';
import 'package:dio/dio.dart';
import 'package:finance/core/services/util_service.dart';
import 'package:finance/core/theme/app_colors.dart';
import 'package:finance/core/widgets/primary_button.dart';
import 'package:finance/models/bank.dart';
import 'package:finance/pages/bank/bank_details_page.dart';
import 'package:finance/repositories/bank_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BankPage extends StatefulWidget {
  const BankPage({super.key});

  @override
  State<BankPage> createState() => _BankPageState();
}

class _BankPageState extends State<BankPage> {
  final _bankRepository = BankRepository();

  bool _isInitLoading = true;
  List<Bank> _banks = [];

  @override
  void initState() {
    super.initState();
    _initial();
  }

  Future<void> _initial() async {
    try {
      setState(() => _isInitLoading = true);
      await _getBanks();
    } finally {
      if (mounted) setState(() => _isInitLoading = false);
    }
  }

  Future<void> _getBanks() async {
    try {
      final response = await _bankRepository.getSelect();
      setState(() {
        _banks = response;
      });
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    }
  }

  Future<void> _navigateToCreate() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const BankDetailsPage(),
      ),
    );

    if (result == true) {
      _initial();
    }
  }

  Future<void> _navigateToEdit(Bank bank) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BankDetailsPage(bank: bank),
      ),
    );

    if (result == true) {
      _initial();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light80,
      appBar: AppBar(
        backgroundColor: AppColors.violet100,
        foregroundColor: AppColors.light100,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Bancos",
          style: TextStyle(
            color: AppColors.light100,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            size: 18,
            color: AppColors.light100,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _initial,
          child: _isInitLoading
              ? const Center(child: CircularProgressIndicator())
              : _banks.isEmpty
                  ? _buildEmptyState()
                  : _buildBankList(),
        ),
      ),
      bottomNavigationBar: Container(
        color: AppColors.light80,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: PrimaryButton(
              isLoading: false,
              text: "Novo Banco",
              onPressed: _navigateToCreate,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.violet20,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.buildingColumns,
                    color: AppColors.violet100,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Nenhum banco",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark75,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Você ainda não possui bancos cadastrados. Clique abaixo para adicionar.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.dark25,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: _banks.length,
      itemBuilder: (context, index) {
        final bank = _banks[index];
        return _buildBankCard(bank);
      },
    );
  }

  Widget _buildBankCard(Bank bank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.light100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToEdit(bank),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.violet20,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.buildingColumns,
                      color: AppColors.violet100,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bank.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark75,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        UtilBrasilFields.obterReal(bank.balance),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.dark25,
                        ),
                      ),
                    ],
                  ),
                ),
                const FaIcon(
                  FontAwesomeIcons.chevronRight,
                  color: AppColors.dark25,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
