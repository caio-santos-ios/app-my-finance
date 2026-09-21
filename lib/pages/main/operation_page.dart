import 'package:brasil_fields/brasil_fields.dart';
import 'package:dio/dio.dart';
import 'package:finance/core/services/util_service.dart';
import 'package:finance/core/theme/app_colors.dart';
import 'package:finance/core/widgets/dropdown_widget.dart';
import 'package:finance/core/widgets/primary_button.dart';
import 'package:finance/core/widgets/text_form_field_widget.dart';
import 'package:finance/core/widgets/toastify_widget.dart';
import 'package:finance/models/bank.dart';
import 'package:finance/models/category.dart';
import 'package:finance/pages/main/main_page.dart';
import 'package:finance/repositories/bank_repository.dart';
import 'package:finance/repositories/category_repository.dart';
import 'package:finance/repositories/operation_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OperationPage extends StatefulWidget {
  const OperationPage({super.key, required this.type});

  final String type;

  @override
  State<OperationPage> createState() => _OperationPageState();
}

class _OperationPageState extends State<OperationPage> {
  final _categoryRepository = CategoryRepository();
  final _bankRepository = BankRepository();
  final _operationRepository = OperationRepository();

  final _valueController = TextEditingController(text: "R\$ 0,00");
  final _descriptionController = TextEditingController(text: "");
  final _categoryController = TextEditingController(text: "");
  final _bankController = TextEditingController(text: "");
  bool _repeat = false;

  bool _isLoading = false;
  bool _isInitLoading = true;

  List<Category> _categories = [];
  List<Bank> _banks = [];

  @override
  void initState() {
    super.initState();
    _initial();
  }

  Future<void> _initial() async {
    setState(() => _isInitLoading = true);
    await _getCategories();
    await _getBanks();
    setState(() => _isInitLoading = false);
  }

  Future<void> _getCategories() async {
    try {
      setState(() => _isInitLoading = true);

      final response = await _categoryRepository.getSelect(widget.type);
      setState(() {
        _categories = response;
      });
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    } finally {
      setState(() => _isInitLoading = false);
    }
  }

  Future<void> _getBanks() async {
    try {
      setState(() => _isInitLoading = true);

      final response = await _bankRepository.getSelect();
      setState(() {
        _banks = response;
      });
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    } finally {
      setState(() => _isInitLoading = false);
    }
  }

  Future<void> _create() async {
    try {
      setState(() => _isLoading = true);

      final rawValue = _valueController.text
          .replaceAll(RegExp(r'[^\d,]'), '')
          .replaceAll(",", ".");

      final response = await _operationRepository.create({
        "bankId": _bankController.text,
        "categoryId": _categoryController.text,
        "description": _descriptionController.text,
        "type": widget.type,
        "value": double.parse(rawValue),
        "repeat": _repeat
      });

      if (mounted) {
        Toastfy.show(context, response.message, "success");

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainPage(initialPage: 0)),
        );
      }
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == "income" ? "Receita" : "Despesa",
          style: TextStyle(color: AppColors.light100),
        ),
        backgroundColor: widget.type == "income" ? Colors.green : Colors.red,
        iconTheme: IconThemeData(color: AppColors.light100),
      ),
      backgroundColor: widget.type == "income" ? Colors.green : Colors.red,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.only(top: 18),
          child: SingleChildScrollView(
            child: RefreshIndicator(
              onRefresh: () async {
                await _getCategories();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isInitLoading) ...[CircularProgressIndicator()],

                  if (!_isInitLoading) ...[
                    SizedBox(height: 45),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: _buildFieldValue(),
                    ),
                    SizedBox(height: 20),
                    _buildForm(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldValue() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quanto?",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight(600),
            color: AppColors.light100,
          ),
        ),
        SizedBox(height: 12),
        TextFormField(
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight(600),
            color: AppColors.light100,
          ),
          controller: _valueController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(0),
            fillColor: Colors.transparent,
            filled: true,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CentavosInputFormatter(moeda: true, casasDecimais: 2),
          ],
        ),
      ],
    );
  }

  Widget _buildForm() {
    double height = MediaQuery.of(context).size.height - 300;

    return Container(
      padding: EdgeInsets.all(18),
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.light100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 14),
          DropdownWidget(
            controller: _categoryController,
            items: _categories
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e.id,
                    child: Text(e.name),
                  ),
                )
                .toList(),
            placeholder: "Categoria",
          ),
          SizedBox(height: 14),
          TextFormFieldWidget(
            controller: _descriptionController,
            placeholder: "Descrição",
            type: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'A Categoria é obrigatória';
              }

              return null;
            },
          ),
          SizedBox(height: 14),
          DropdownWidget(
            controller: _bankController,
            items: _banks
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e.id,
                    child: Text(e.name),
                  ),
                )
                .toList(),
            placeholder: "Banco",
          ),
          SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Repita",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleMedium?.color,
                      fontWeight: Theme.of(
                        context,
                      ).textTheme.titleMedium?.fontWeight,
                      fontSize: 26,
                    ),
                  ),
                  Text(
                    "Repetir transação",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              ),
              Switch(
                value: _repeat,
                onChanged: (value) {
                  setState(() {
                    _repeat = value;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 40),
          PrimaryButton(
            isLoading: _isLoading,
            text: "Salvar",
            onPressed: () async {
              await _create();
            },
          ),
        ],
      ),
    );
  }
}
