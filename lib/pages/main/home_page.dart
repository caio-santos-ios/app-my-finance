import 'package:brasil_fields/brasil_fields.dart';
import 'package:dio/dio.dart';
import 'package:finance/core/services/util_service.dart';
import 'package:finance/core/theme/app_colors.dart';
import 'package:finance/models/dashboard.dart';
import 'package:finance/models/operation.dart';
import 'package:finance/repositories/dashboard_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _dashboardRepository = DashboardRepository();

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
    operations: [],
  );

  @override
  void initState() {
    super.initState();
    DateTime today = DateTime.now();
    _monthController.text = _months[today.month - 1];

    _get();
  }

  Future<void> _get() async {
    try {
      setState(() => _isInitLoading = true);
      DateTime today = DateTime.now();
      final response = await _dashboardRepository.get(today, today);
      setState(() {
        _dashboard = response!;
      });
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    } finally {
      setState(() => _isInitLoading = false);
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        centerTitle: true,

        leadingWidth: width,
        leading: Padding(
          padding: EdgeInsetsGeometry.only(left: 18, right: 18, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FaIcon(FontAwesomeIcons.user),
              SizedBox(
                width: 150,
                child: DropdownButtonFormField(
                  initialValue: _monthController.text,
                  items: _months
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {},
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              FaIcon(
                FontAwesomeIcons.solidBell,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isInitLoading) ...[
                Center(child: CircularProgressIndicator()),
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
                    itemCount: _dashboard.operations.length,
                    itemBuilder: (context, index) {
                      Operation operation = _dashboard.operations[index];

                      return _buildCardOperation(operation);
                    },
                  ),
                ),
                SizedBox(height: 20),
              ],
            ],
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
    return Card(
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
                  decoration: BoxDecoration(color: Colors.amberAccent[100], borderRadius: BorderRadius.circular(14)),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.dollarSign,
                      color: Colors.amber,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Categoria",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      operation.description,
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
                  UtilBrasilFields.obterReal(operation.value),
                  style: TextStyle(
                    color: operation.type == "income"
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                Text(
                  "03:00",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
