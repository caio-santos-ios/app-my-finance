import 'package:brasil_fields/brasil_fields.dart';
import 'package:dio/dio.dart';
import 'package:finance/core/services/util_service.dart';
import 'package:finance/core/theme/app_colors.dart';
import 'package:finance/core/widgets/primary_button.dart';
import 'package:finance/models/budget.dart';
import 'package:finance/pages/budget/budget_details_page.dart';
import 'package:finance/repositories/budget_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final _budgetRepository = BudgetRepository();

  bool _isInitLoading = true;
  List<Budget> _budgets = [];

  final List<String> _months = [
    "Janeiro",
    "Fevereiro",
    "Março",
    "Abril",
    "Maio",
    "Junho",
    "Julho",
    "Agosto",
    "Setembro",
    "Outubro",
    "Novembro",
    "Dezembro",
  ];

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _initial();
  }

  Future<void> _initial() async {
    try {
      setState(() => _isInitLoading = true);
      await _getBudgets();
    } finally {
      setState(() => _isInitLoading = false);
    }
  }

  Future<void> _getBudgets() async {
    try {
      final response = await _budgetRepository.get();
      setState(() {
        _budgets = response;
      });
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    }
  }

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });
    _initial();
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });
    _initial();
  }

  Future<void> _navigateToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BudgetDetailsPage(),
      ),
    );

    if (result == true) {
      _initial();
    }
  }

  Future<void> _navigateToEdit(Budget budget) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetDetailsPage(budget: budget),
      ),
    );

    if (result == true) {
      _initial();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.violet100,
      body: SafeArea(
        child: Column(
          children: [
            _buildMonthHeader(),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
                decoration: const BoxDecoration(
                  color: AppColors.light80,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: RefreshIndicator(
                  onRefresh: _initial,
                  child: _isInitLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _budgets.isEmpty
                          ? _buildEmptyState()
                          : _buildBudgetList(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: AppColors.light80,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: PrimaryButton(
          isLoading: false,
          text: "Criar um Orçamento",
          onPressed: _navigateToCreate,
        ),
      ),
    );
  }

  Widget _buildMonthHeader() {
    final monthName = _months[_selectedDate.month - 1];
    final year = _selectedDate.year;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.chevronLeft,
              color: AppColors.light100,
              size: 18,
            ),
            onPressed: _previousMonth,
          ),
          Text(
            "$monthName $year",
            style: const TextStyle(
              color: AppColors.light100,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.chevronRight,
              color: AppColors.light100,
              size: 18,
            ),
            onPressed: _nextMonth,
          ),
        ],
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
                decoration: BoxDecoration(
                  color: AppColors.violet20,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.chartPie,
                    color: AppColors.violet100,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Nenhum orçamento",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark75,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Você ainda não criou nenhum orçamento para este mês. Comece agora para controlar suas despesas!",
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

  Widget _buildBudgetList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _budgets.length,
      padding: const EdgeInsets.only(bottom: 24),
      itemBuilder: (context, index) {
        final budget = _budgets[index];
        return _buildBudgetCard(budget);
      },
    );
  }

  Widget _buildBudgetCard(Budget budget) {
    final bool isExceeded = budget.spent > budget.limit;
    final double progress = budget.limit > 0
        ? (budget.spent / budget.limit).clamp(0.0, 1.0)
        : 0.0;
    final bool isNearLimit = (budget.limit > 0) &&
        (budget.spent / budget.limit >= (budget.alertPercentage / 100));

    Color progressColor = AppColors.violet100;
    if (isExceeded) {
      progressColor = AppColors.red100;
    } else if (isNearLimit) {
      progressColor = AppColors.yellow100;
    }

    final categoryName = budget.categoryName ?? budget.name;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          onTap: () => _navigateToEdit(budget),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.light40,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.light20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: progressColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            categoryName.isEmpty ? "Orçamento" : categoryName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dark75,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isExceeded)
                      const Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppColors.red100,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Excedido!",
                            style: TextStyle(
                              color: AppColors.red100,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    else if (isNearLimit && budget.receiveAlert)
                      const Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.yellow100,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Alerta!",
                            style: TextStyle(
                              color: AppColors.yellow100,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  isExceeded
                      ? "Excedeu em ${UtilBrasilFields.obterReal(budget.spent - budget.limit)}"
                      : "Restante ${UtilBrasilFields.obterReal(budget.remaining > 0 ? budget.remaining : (budget.limit - budget.spent))}",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isExceeded ? AppColors.red100 : AppColors.dark75,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: AppColors.light40,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${UtilBrasilFields.obterReal(budget.spent)} de ${UtilBrasilFields.obterReal(budget.limit)}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.dark25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${(progress * 100).toInt()}%",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
                if (isExceeded) ...[
                  const SizedBox(height: 6),
                  const Text(
                    "Você ultrapassou o limite deste orçamento",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.red100,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
