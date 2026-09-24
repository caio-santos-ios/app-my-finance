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
import 'package:finance/models/operation.dart';
import 'package:finance/repositories/bank_repository.dart';
import 'package:finance/repositories/category_repository.dart';
import 'package:finance/repositories/operation_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OperationDetailsPage extends StatefulWidget {
  const OperationDetailsPage({super.key, required this.type, this.operation});

  final String type;
  final Operation? operation;

  @override
  State<OperationDetailsPage> createState() => _OperationDetailsPageState();
}

class _OperationDetailsPageState extends State<OperationDetailsPage> {
  final _categoryRepository = CategoryRepository();
  final _bankRepository = BankRepository();
  final _operationRepository = OperationRepository();

  final _valueController = TextEditingController(text: "R\$ 0,00");
  final _descriptionController = TextEditingController(text: "");
  final _categoryController = TextEditingController(text: "");
  final _bankController = TextEditingController(text: "");
  final _destinationBankController = TextEditingController(text: "");
  bool _repeat = false;

  bool _isLoading = false;
  bool _isInitLoading = true;

  List<Category> _categories = [];
  List<Bank> _banks = [];

  bool get isEditing => widget.operation != null;

  Color get _themeColor {
    switch (widget.type) {
      case "income":
        return Colors.green;
      case "expense":
        return Colors.red;
      case "transfer":
        return const Color(0xFF0077FF);
      default:
        return Colors.blue;
    }
  }

  String get _pageTitle {
    if (isEditing) {
      switch (widget.type) {
        case "income":
          return "Editar Receita";
        case "expense":
          return "Editar Despesa";
        case "transfer":
          return "Editar Transferência";
        default:
          return "Editar Operação";
      }
    } else {
      switch (widget.type) {
        case "income":
          return "Receita";
        case "expense":
          return "Despesa";
        case "transfer":
          return "Transferência";
        default:
          return "Operação";
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.operation != null) {
      setState(() {
        _valueController.text = UtilBrasilFields.obterReal(
          widget.operation!.value,
        );
        _descriptionController.text = widget.operation!.description;
        _categoryController.text = widget.operation!.categoryId;
        _bankController.text = widget.operation!.bankId;
        _destinationBankController.text =
            widget.operation!.destinationBankId ?? "";
        _repeat = widget.operation!.repeat;
      });
    }
    _initial();
  }

  Future<void> _initial() async {
    setState(() => _isInitLoading = true);
    if (widget.type != "transfer") {
      await _getCategories();
    }
    await _getBanks();
    setState(() => _isInitLoading = false);
  }

  Future<void> _getCategories() async {
    try {
      final response = await _categoryRepository.getSelect(widget.type);
      setState(() {
        _categories = response;
      });
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
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

  Future<void> _save() async {
    try {
      final rawValue = _valueController.text
          .replaceAll(RegExp(r'[^\d,]'), '')
          .replaceAll(",", ".");
      final value = double.tryParse(rawValue) ?? 0.0;

      if (value <= 0) {
        Toastfy.show(context, "O Valor deve ser maior que zero", "warning");
        return;
      }
      if (widget.type == "transfer") {
        if (_bankController.text.isEmpty) {
          Toastfy.show(context, "A Conta de origem é obrigatória", "warning");
          return;
        }
        if (_destinationBankController.text.isEmpty) {
          Toastfy.show(context, "A Conta de destino é obrigatória", "warning");
          return;
        }
        if (_bankController.text == _destinationBankController.text) {
          Toastfy.show(
            context,
            "A Conta de origem e destino devem ser diferentes",
            "warning",
          );
          return;
        }
      } else {
        if (_categoryController.text.isEmpty) {
          Toastfy.show(context, "A Categoria é obrigatória", "warning");
          return;
        }
        if (_bankController.text.isEmpty) {
          Toastfy.show(context, "O Banco é obrigatório", "warning");
          return;
        }
      }

      final data = {
        if (isEditing) "id": widget.operation!.id,
        "bankId": _bankController.text,
        if (widget.type != "transfer") "categoryId": _categoryController.text,
        if (widget.type == "transfer")
          "destinationBankId": _destinationBankController.text,
        "description": _descriptionController.text,
        "type": widget.type,
        "value": value,
        "repeat": widget.type == "transfer" ? false : _repeat,
      };

      final response = isEditing
          ? await _operationRepository.update(data)
          : await _operationRepository.create(data);

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
        title: const Text("Excluir Operação"),
        content: const Text("Tem certeza que deseja excluir esta operação?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() => _isLoading = true);
      await _operationRepository.delete(widget.operation!.id);
      if (mounted) {
        Toastfy.show(context, "Excluido com sucesso", "success");
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
      appBar: AppBar(
        title: Text(_pageTitle, style: TextStyle(color: AppColors.light100)),
        backgroundColor: _themeColor,
        iconTheme: IconThemeData(color: AppColors.light100),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _isLoading ? null : _delete,
            ),
        ],
      ),
      backgroundColor: _themeColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(top: 18),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      if (widget.type != "transfer") {
                        await _getCategories();
                      }
                      await _getBanks();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isInitLoading)
                          const Center(child: CircularProgressIndicator()),

                        if (!_isInitLoading) ...[
                          const SizedBox(height: 45),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: _buildFieldValue(),
                          ),
                          const SizedBox(height: 20),
                          _buildForm(),
                        ],
                      ],
                    ),
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
        Text(
          "Quanto?",
          style: TextStyle(
            fontSize: 16,
            fontWeight: const FontWeight(600),
            color: AppColors.light100,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          style: TextStyle(
            fontSize: 50,
            fontWeight: const FontWeight(600),
            color: AppColors.light100,
          ),
          controller: _valueController,
          decoration: const InputDecoration(
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
    double minHeight = MediaQuery.of(context).size.height - 300;

    return Container(
      padding: const EdgeInsets.all(18),
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        color: AppColors.light100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: widget.type == "transfer"
          ? _buildTransferForm()
          : _buildStandardForm(),
    );
  }

  Widget _buildTransferForm() {
    return Column(
      children: [
        const SizedBox(height: 14),
        DropdownWidget(
          controller: _bankController,
          items: _banks
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e.id,
                  child: Text(e.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          placeholder: "De",
        ),
        const SizedBox(height: 14),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF0077FF).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: FaIcon(
              FontAwesomeIcons.arrowRightArrowLeft,
              color: Color(0xFF0077FF),
              size: 14,
            ),
          ),
        ),
        const SizedBox(height: 14),
        DropdownWidget(
          controller: _destinationBankController,
          items: _banks
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e.id,
                  child: Text(e.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          placeholder: "Para",
        ),
        const SizedBox(height: 14),
        TextFormFieldWidget(
          controller: _descriptionController,
          placeholder: "Descrição",
          type: TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'A Descrição é obrigatória';
            }
            return null;
          },
        ),
        const SizedBox(height: 40),
        PrimaryButton(
          isLoading: _isLoading,
          text: isEditing ? "Atualizar" : "Salvar",
          onPressed: () async {
            await _save();
          },
        ),
      ],
    );
  }

  Widget _buildStandardForm() {
    return Column(
      children: [
        const SizedBox(height: 14),
        DropdownWidget(
          controller: _categoryController,
          items: _categories
              .map(
                (e) =>
                    DropdownMenuItem<String>(value: e.id, child: Text(e.name)),
              )
              .toList(),
          placeholder: "Categoria",
        ),
        const SizedBox(height: 14),
        TextFormFieldWidget(
          controller: _descriptionController,
          placeholder: "Descrição",
          type: TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'A Descrição é obrigatória';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        DropdownWidget(
          controller: _bankController,
          items: _banks
              .map(
                (e) =>
                    DropdownMenuItem<String>(value: e.id, child: Text(e.name)),
              )
              .toList(),
          placeholder: "Banco",
        ),
        const SizedBox(height: 14),
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
        const SizedBox(height: 40),
        PrimaryButton(
          isLoading: _isLoading,
          text: isEditing ? "Atualizar" : "Salvar",
          onPressed: () async {
            await _save();
          },
        ),
      ],
    );
  }
}
