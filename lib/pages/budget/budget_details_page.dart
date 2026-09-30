import 'package:brasil_fields/brasil_fields.dart';
import 'package:dio/dio.dart';
import 'package:finance/core/services/util_service.dart';
import 'package:finance/core/theme/app_colors.dart';
import 'package:finance/core/widgets/dropdown_widget.dart';
import 'package:finance/core/widgets/primary_button.dart';
import 'package:finance/core/widgets/toastify_widget.dart';
import 'package:finance/models/budget.dart';
import 'package:finance/models/category.dart';
import 'package:finance/repositories/budget_repository.dart';
import 'package:finance/repositories/category_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BudgetDetailsPage extends StatefulWidget {
  const BudgetDetailsPage({super.key, this.budget});

  final Budget? budget;

  @override
  State<BudgetDetailsPage> createState() => _BudgetDetailsPageState();
}

class _BudgetDetailsPageState extends State<BudgetDetailsPage> {
  final _budgetRepository = BudgetRepository();
  final _categoryRepository = CategoryRepository();

  final _valueController = TextEditingController(text: "R\$ 0,00");
  final _categoryController = TextEditingController(text: "");

  bool _receiveAlert = true;
  double _alertPercentage = 80.0;
  bool _isLoading = false;
  bool _isInitLoading = true;

  List<Category> _categories = [];

  bool get isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _valueController.text = UtilBrasilFields.obterReal(widget.budget!.limit);
      _categoryController.text = widget.budget!.categoryId;
      _receiveAlert = widget.budget!.receiveAlert;
      _alertPercentage = widget.budget!.alertPercentage.toDouble();
    }
    _initial();
  }

  @override
  void dispose() {
    _valueController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _initial() async {
    try {
      setState(() => _isInitLoading = true);
      await _getCategories();
    } finally {
      setState(() => _isInitLoading = false);
    }
  }

  Future<void> _getCategories() async {
    try {
      final response = await _categoryRepository.getSelect("expense");
      setState(() {
        _categories = response;
      });
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    }
  }

  Future<void> _save() async {
    try {
      final rawValue = _valueController.text
          .replaceAll(RegExp(r'[^\d,]'), '')
          .replaceAll(",", ".");
      final value = double.tryParse(rawValue) ?? 0.0;

      if (value <= 0) {
        Toastfy.show(context, "O Limite deve ser maior que zero", "warning");
        return;
      }

      if (_categoryController.text.isEmpty) {
        Toastfy.show(context, "A Categoria é obrigatória", "warning");
        return;
      }

      setState(() => _isLoading = true);

      final data = {
        if (isEditing) "id": widget.budget!.id,
        "categoryId": _categoryController.text,
        "limit": value,
        "receiveAlert": _receiveAlert,
        "alertPercentage": _alertPercentage.toInt(),
      };

      final response = isEditing
          ? await _budgetRepository.update(data)
          : await _budgetRepository.create(data);

      if (mounted) {
        Toastfy.show(context, response.message, "success");
        Navigator.pop(context, true);
      }
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    if (!isEditing) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Orçamento"),
        content: const Text("Tem certeza que deseja excluir este orçamento?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red100),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() => _isLoading = true);
      await _budgetRepository.delete(widget.budget!.id);
      if (mounted) {
        Toastfy.show(context, "Excluído com sucesso", "success");
        Navigator.pop(context, true);
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
      backgroundColor: AppColors.violet100,
      appBar: AppBar(
        title: Text(
          isEditing ? "Editar Orçamento" : "Criar Orçamento",
          style: const TextStyle(color: AppColors.light100, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.violet100,
        iconTheme: const IconThemeData(color: AppColors.light100),
        elevation: 0,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _isLoading ? null : _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(top: 18),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (_isInitLoading)
                        const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.light100),
                          ),
                        ),

                      if (!_isInitLoading) ...[
                        const SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildFieldValue(),
                        ),
                        const SizedBox(height: 25),
                        Expanded(child: _buildForm()),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFieldValue() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quanto você quer gastar?",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.light80,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.light100,
          ),
          controller: _valueController,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.zero,
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
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.light100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          DropdownWidget(
            controller: _categoryController,
            items: _categories
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e.id,
                    child: Text(e.name, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            placeholder: "Selecione a Categoria",
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Receber Alerta",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark75,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Receba um aviso quando atingir o limite estipulado",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.dark25,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _receiveAlert,
                activeThumbColor: AppColors.violet100,
                activeTrackColor: AppColors.violet20,
                onChanged: (val) {
                  setState(() => _receiveAlert = val);
                },
              ),
            ],
          ),
          if (_receiveAlert) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Porcentagem do alerta",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.dark50,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.violet20,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${_alertPercentage.toInt()}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.violet100,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: _alertPercentage,
              min: 10,
              max: 100,
              divisions: 18,
              activeColor: AppColors.violet100,
              inactiveColor: AppColors.light20,
              onChanged: (val) {
                setState(() => _alertPercentage = val);
              },
            ),
          ],
          const Spacer(),
          const SizedBox(height: 24),
          PrimaryButton(
            isLoading: _isLoading,
            text: isEditing ? "Salvar Alterações" : "Continuar",
            onPressed: () async {
              await _save();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
