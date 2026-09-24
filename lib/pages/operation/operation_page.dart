import 'package:brasil_fields/brasil_fields.dart';
import 'package:dio/dio.dart';
import 'package:finance/core/services/util_service.dart';
import 'package:finance/models/operation.dart';
import 'package:finance/pages/operation/operation_details_page.dart';
import 'package:finance/repositories/operation_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OperationPage extends StatefulWidget {
  const OperationPage({super.key});

  @override
  State<OperationPage> createState() => _OperationPageState();
}

class _OperationPageState extends State<OperationPage> {
  final _operationRepository = OperationRepository();

  bool _isInitLoading = true;

  List<Operation> _operations = [];

  @override
  void initState() {
    super.initState();
    _initial();
  }

  Future<void> _initial() async {
    // setState(() => _isInitLoading = true);
    // await _getOperations();
    // setState(() => _isInitLoading = false);
  }

  Future<void> _getOperations() async {
    try {
      setState(() => _isInitLoading = true);

      final response = await _operationRepository.get();
      setState(() {
        _operations = response;
      });
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    } finally {
      setState(() => _isInitLoading = false);
    }
  }

  String _normalizeValueCardOperation(double value, String type) {
    if (type == "income") return "+ ${UtilBrasilFields.obterReal(value)}";
    if (type == "expense") return "- ${UtilBrasilFields.obterReal(value)}";

    return UtilBrasilFields.obterReal(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: RefreshIndicator(
            onRefresh: () async {
              await _getOperations();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isInitLoading) ...[
                  Center(child: const CircularProgressIndicator()),
                ],

                if (!_isInitLoading) ...[
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

  Widget _buildCardOperation(Operation operation) {
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
            _getOperations();
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
                          : Colors.amberAccent[100],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: FaIcon(
                        operation.type == "transfer"
                            ? FontAwesomeIcons.arrowRightArrowLeft
                            : FontAwesomeIcons.dollarSign,
                        color: operation.type == "transfer"
                            ? const Color(0xFF0077FF)
                            : Colors.amber,
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
                            : "Categoria",
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
                    "03:00",
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
