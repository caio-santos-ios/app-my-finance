import 'package:brasil_fields/brasil_fields.dart';
import 'package:dio/dio.dart';
import 'package:finance/core/services/util_service.dart';
import 'package:finance/core/theme/app_colors.dart';
import 'package:finance/core/widgets/app_bar_widget.dart';
import 'package:finance/models/dashboard.dart';
import 'package:finance/models/operation.dart';
import 'package:finance/pages/operation/operation_details_page.dart';
import 'package:finance/repositories/dashboard_repository.dart';
import 'package:finance/repositories/operation_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _dashboardRepository = DashboardRepository();
  final _operationRepository = OperationRepository();

  final _months = [
    "janeiro",
    "fevereiro",
    "março",
    "abril",
    "maio",
    "junho",
    "julho",
    "agosto",
    "setembro",
    "outubro",
    "novembro",
    "dezembro",
  ];
  late DateTime _selectedDate;

  bool _isInitLoading = true;
  Dashboard _dashboard = Dashboard(
    totalAccount: 0,
    totalAccountIncome: 0,
    totalAccountExpense: 0,
  );
  List<Operation> _operations = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    DateTime today = DateTime.now();
    DateTime startDate = DateTime(today.year, today.month, 1);
    _initial(startDate, today);
  }

  Future<void> _initial(DateTime startDate, DateTime endDate) async {
    try {
      setState(() => _isInitLoading = true);
      String query =
          "gte\$and\$createdAt\$date=$startDate&lte\$and\$createdAt\$date=$endDate";
      await _get(startDate, endDate);
      await _getSelectOperation(query);
    } finally {
      setState(() => _isInitLoading = false);
    }
  }

  Future<void> _get(DateTime startDate, DateTime endDate) async {
    try {
      final response = await _dashboardRepository.get(startDate, endDate);
      setState(() {
        _dashboard = response!;
      });
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    }
  }

  Future<void> _getSelectOperation(String query) async {
    try {
      final response = await _operationRepository.get(query: query);
      setState(() {
        _operations = response;
      });
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    }
  }

  void _previousMonth() async {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });

    DateTime startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    DateTime endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    await _initial(startDate, endDate);
  }

  void _nextMonth() async {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });

    DateTime startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    DateTime endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    await _initial(startDate, endDate);
  }

  String _normalizeValue(double value) {
    if (value < 1000) return UtilBrasilFields.obterReal(value);

    if (value < 1000000) {
      final k = value / 1000;
      final formatted = k == k.roundToDouble()
          ? k.toStringAsFixed(0)
          : k.toStringAsFixed(1);
      return "R\$ ${formatted}K";
    }

    final m = value / 1000000;
    final formatted = m == m.roundToDouble()
        ? m.toStringAsFixed(0)
        : m.toStringAsFixed(1);
    return "R\$ ${formatted}M";
  }

  String _normalizeValueCardOperation(double value, String type) {
    if (type == "income") return "+ ${UtilBrasilFields.obterReal(value)}";
    if (type == "expense") return "- ${UtilBrasilFields.obterReal(value)}";

    return UtilBrasilFields.obterReal(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(titleText: ""),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.all(18),
          child: RefreshIndicator(
            onRefresh: () async {
              DateTime startDate = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                1,
              );
              DateTime endDate = DateTime(
                _selectedDate.year,
                _selectedDate.month + 1,
                0,
              );

              await _initial(startDate, endDate);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isInitLoading) ...[
                  Center(child: const CircularProgressIndicator()),
                ],

                if (!_isInitLoading) ...[
                  _buildFilterMonth(),
                  SizedBox(height: 20),
                  _buildAccountBalance(),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCardIncomeExpense(
                        "income",
                        _dashboard.totalAccountIncome,
                      ),
                      _buildCardIncomeExpense(
                        "expense",
                        _dashboard.totalAccountExpense,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _operations.length,
                      itemBuilder: (context, index) {
                        Operation operation = _operations[index];

                        return _buildCardOperation(operation);
                      },
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

  Widget _buildFilterMonth() {
    final monthName = _months[_selectedDate.month - 1];
    final year = _selectedDate.year;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.chevronLeft,
            color: AppColors.dark75,
            size: 14,
          ),
          onPressed: _previousMonth,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.light100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.light20),
          ),
          child: Text(
            "$monthName $year",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.dark75,
            ),
          ),
        ),
        IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.chevronRight,
            color: AppColors.dark75,
            size: 14,
          ),
          onPressed: _nextMonth,
        ),
      ],
    );
  }

  Widget _buildAccountBalance() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Text(
            "Saldo da conta",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Text(
            UtilBrasilFields.obterReal(_dashboard.totalAccount),
            style: TextStyle(
              color: Theme.of(context).textTheme.titleMedium?.color,
              fontWeight: Theme.of(context).textTheme.titleMedium?.fontWeight,
              fontSize: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardIncomeExpense(String type, double value) {
    return Container(
      width: (MediaQuery.of(context).size.width / 2) - 26,
      height: 70,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: type == "income" ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        spacing: 4,
        children: [
          Container(
            width: 50,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.light100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FaIcon(
                  type == "income"
                      ? FontAwesomeIcons.arrowUp
                      : FontAwesomeIcons.arrowDown,
                  color: type == "income" ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type == "income" ? "Receita" : "Despesa",
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.headlineLarge?.fontSize,
                  color: AppColors.light100,
                ),
              ),
              Text(
                _normalizeValue(value),
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleSmall?.fontSize,
                  color: AppColors.light100,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardOperation(Operation operation) {
    final isTransfer = operation.type == "transfer";
    final isIncome = operation.type == "income";

    Color iconBgColor = AppColors.red20;
    Color iconColor = AppColors.red100;
    FaIconData icon = FontAwesomeIcons.dollarSign;

    if (isTransfer) {
      iconBgColor = AppColors.blue20;
      iconColor = AppColors.blue100;
      icon = FontAwesomeIcons.arrowRightArrowLeft;
    } else if (isIncome) {
      iconBgColor = AppColors.green20;
      iconColor = AppColors.green100;
      icon = FontAwesomeIcons.dollarSign;
    }

    final categoryTitle = isTransfer
        ? "Transferência"
        : (operation.categoryName.isNotEmpty
              ? operation.categoryName
              : "Sem categoria");

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.light100,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OperationDetailsPage(
                  type: operation.type,
                  operation: operation,
                ),
              ),
            );
            if (result == true) {
              _selectedDate = DateTime.now();
              DateTime startDate = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                1,
              );
              DateTime endDate = DateTime(
                _selectedDate.year,
                _selectedDate.month + 1,
                0,
              );

              await _initial(startDate, endDate);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: FaIcon(icon, color: iconColor, size: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoryTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.dark75,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              operation.description.isNotEmpty
                                  ? operation.description
                                  : "Sem descrição",
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.dark25,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _normalizeValueCardOperation(
                        operation.value,
                        operation.type,
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isIncome
                            ? AppColors.green100
                            : isTransfer
                            ? AppColors.blue100
                            : AppColors.red100,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat("dd/MM HH:mm").format(operation.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.dark25,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
