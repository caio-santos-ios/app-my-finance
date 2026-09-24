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

  final _monthController = TextEditingController(text: "janeiro");
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
    DateTime today = DateTime.now();
    _monthController.text = _months[today.month - 1];

    _initial();
  }

  Future<void> _initial() async {
    setState(() => _isInitLoading = true);
    await _get();
    await _getSelectOperation();
    setState(() => _isInitLoading = false);
  }

  Future<void> _get() async {
    try {
      DateTime today = DateTime.now();
      final response = await _dashboardRepository.get(today, today);
      setState(() {
        _dashboard = response!;
      });
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    }
  }

  Future<void> _getSelectOperation() async {
    try {
      DateTime today = DateTime.now();
      final response = await _operationRepository.get(
        query:
            "gte\$and\$createdAt\$date=$today&lte\$and\$createdAt\$date=$today",
      );
      setState(() {
        _operations = response;
      });
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    }
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
              await _initial();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isInitLoading) ...[
                  Center(child: const CircularProgressIndicator()),
                ],

                if (!_isInitLoading) ...[
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
    String maxText(String text, int max) {
      if (text.length >= max) return "${text.substring(0, max)}...";

      return text;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
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
            await _initial();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 8,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: operation.type == "transfer"
                          ? const Color(0xFF0077FF).withValues(alpha: 0.2)
                          : operation.type == "income"
                          ? Colors.green[100]
                          : Colors.red[100],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: FaIcon(
                        operation.type == "transfer"
                            ? FontAwesomeIcons.arrowRightArrowLeft
                            : FontAwesomeIcons.dollarSign,
                        color: operation.type == "transfer"
                            ? const Color(0xFF0077FF)
                            : operation.type == "income"
                            ? Colors.green
                            : Colors.red,
                        size: operation.type == "transfer" ? 16 : null,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        operation.type == "transfer"
                            ? "Transferência"
                            : maxText(operation.categoryName, 20),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        operation.description.isEmpty ? "sem descrição" : maxText(operation.description, 30),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _normalizeValueCardOperation(
                      operation.value,
                      operation.type,
                    ),
                    style: TextStyle(
                      color: operation.type == "income"
                          ? Colors.green
                          : operation.type == "expense"
                          ? Colors.red
                          : const Color(0xFF0077FF),
                      fontWeight: FontWeight(600),
                    ),
                  ),
                  Text(
                    DateFormat("dd/MM HH:mm").format(operation.createdAt),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
