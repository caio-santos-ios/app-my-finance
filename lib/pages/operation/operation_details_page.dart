import 'package:brasil_fields/brasil_fields.dart';
import 'package:dio/dio.dart';
import 'package:finance/core/services/util_service.dart';
import 'package:finance/core/theme/app_colors.dart';
import 'package:finance/core/widgets/dropdown_widget.dart';
import 'package:finance/core/widgets/primary_button.dart';
import 'package:finance/core/widgets/text_form_field_widget.dart';
import 'package:finance/core/widgets/toastify_widget.dart';
import 'package:finance/models/_response_api.dart';
import 'package:finance/models/bank.dart';
import 'package:finance/models/category.dart';
import 'package:finance/models/operation.dart';
import 'package:finance/repositories/attachment_repository.dart';
import 'package:finance/repositories/bank_repository.dart';
import 'package:finance/repositories/category_repository.dart';
import 'package:finance/repositories/operation_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

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
  final _attachmentRepository = AttachmentRepository();

  final _valueController = TextEditingController(text: "R\$ 0,00");
  final _descriptionController = TextEditingController(text: "");
  final _categoryController = TextEditingController(text: "");
  final _bankController = TextEditingController(text: "");
  final _destinationBankController = TextEditingController(text: "");
  final _dateController = TextEditingController(text: "");
  final _timeController = TextEditingController(text: "");
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _repeat = false;
  String _recurrence = "";
  final _picker = ImagePicker();

  bool _isLoading = false;
  bool _isInitLoading = true;
  String _idTemp = "";

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

  String _getRecurrenceLabel(String recurrence) {
    switch (recurrence) {
      case "weekly":
        return "Semanal";
      case "monthly":
        return "Mensal";
      case "yearly":
        return "Anual";
      default:
        return "";
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
        _recurrence = widget.operation!.recurrence;
        _selectedDate = widget.operation!.createdAt;
        _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
        _dateController.text = DateFormat("dd/MM/yyyy").format(_selectedDate);
        _timeController.text = DateFormat("HH:mm").format(_selectedDate);
      });
    } else {
      _idTemp = Uuid().v4();
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
      _dateController.text = DateFormat("dd/MM/yyyy").format(_selectedDate);
      _timeController.text = DateFormat("HH:mm").format(_selectedDate);
    }
    _initial();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat("dd/MM/yyyy").format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _timeController.text = "$hour:$minute";
      });
    }
  }

  Future<void> _showRecurrenceModal() async {
    final tempController = TextEditingController(
      text: _recurrence.isNotEmpty ? _recurrence : "monthly",
    );

    final String? selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.light100,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.light20,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                "Frequência da Repetição",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark75,
                ),
              ),
              const SizedBox(height: 16),
              DropdownWidget(
                controller: tempController,
                items: const [
                  DropdownMenuItem<String>(
                    value: "weekly",
                    child: Text("Semanal"),
                  ),
                  DropdownMenuItem<String>(
                    value: "monthly",
                    child: Text("Mensal"),
                  ),
                  DropdownMenuItem<String>(
                    value: "yearly",
                    child: Text("Anual"),
                  ),
                ],
                placeholder: "Recorrência",
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                isLoading: false,
                text: "Próximo",
                onPressed: () {
                  if (tempController.text.isEmpty) {
                    Toastfy.show(
                      context,
                      "Selecione a recorrência",
                      "warning",
                    );
                    return;
                  }
                  Navigator.pop(ctx, tempController.text);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );

    if (selected != null && selected.isNotEmpty) {
      setState(() {
        _repeat = true;
        _recurrence = selected;
      });
    } else if (_recurrence.isEmpty) {
      setState(() {
        _repeat = false;
      });
    }
  }

  Future<void> _initial() async {
    try {
      setState(() => _isInitLoading = true);
      if (widget.type != "transfer") {
        await _getCategories();
      }
      await _getBanks();
    } finally {
      setState(() => _isInitLoading = false);
    }
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
        if (_repeat && _recurrence.isEmpty) {
          Toastfy.show(context, "A Recorrência é obrigatória", "warning");
          return;
        }
      }

      final isRepeating = widget.type == "transfer" ? false : _repeat;
      final datePart = DateFormat("yyyy-MM-dd").format(_selectedDate);
      final timePart =
          "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}";

      final data = {
        if (isEditing) "id": widget.operation!.id,
        "bankId": _bankController.text,
        if (widget.type != "transfer") "categoryId": _categoryController.text,
        if (widget.type == "transfer")
          "destinationBankId": _destinationBankController.text,
        "description": _descriptionController.text,
        "type": widget.type,
        "value": value,
        "createdAt": "${datePart}T$timePart:00Z",
        "repeat": isRepeating,
        "recurrence": isRepeating ? _recurrence : "",
        "parentId": _idTemp,
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

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      FormData data = FormData.fromMap({
        'parentId': isEditing ? widget.operation?.id : _idTemp,
        'parent': 'operations',
        'file': await MultipartFile.fromFile(
          pickedFile.path,
          filename: pickedFile.name,
        ),
      });

      ResponseApi response = await _attachmentRepository.create(data);

      if (mounted) {
        Toastfy.show(context, response.message, "success");
        Navigator.pop(context);
      }
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
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _buildDateField()),
            const SizedBox(width: 12),
            Expanded(child: _buildTimeField()),
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
          children: [
            Expanded(child: _buildDateField()),
            const SizedBox(width: 12),
            Expanded(child: _buildTimeField()),
          ],
        ),
        const SizedBox(height: 14),
        _buildFieldAttachment(),
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
              onChanged: (value) async {
                if (value) {
                  await _showRecurrenceModal();
                } else {
                  setState(() {
                    _repeat = false;
                    _recurrence = "";
                  });
                }
              },
            ),
          ],
        ),
        if (_repeat && _recurrence.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.light80,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.light20),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Frequência",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark75,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getRecurrenceLabel(_recurrence),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.dark25,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _showRecurrenceModal,
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.violet20,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Editar",
                      style: TextStyle(
                        color: AppColors.violet100,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      onTap: _selectDate,
      style: TextStyle(color: AppColors.dark50),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        hintText: "Data de Lançamento",
        hintStyle: TextStyle(color: AppColors.dark25),
        filled: true,
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.calendar,
                color: Theme.of(context).textTheme.headlineLarge?.color,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return TextFormField(
      controller: _timeController,
      readOnly: true,
      onTap: _selectTime,
      style: TextStyle(color: AppColors.dark50),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        hintText: "Hora de Lançamento",
        hintStyle: TextStyle(color: AppColors.dark25),
        filled: true,
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.clock,
                color: Theme.of(context).textTheme.headlineLarge?.color,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldAttachment() {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(14),
              height: 200,
              width: double.infinity,
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.violet40,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 14,
                    children: [
                      Container(
                        height: 80,
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.violet40,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.solidCamera,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            Text(
                              "Camera",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 16,
                                fontWeight: FontWeight(600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await _pickImage(ImageSource.gallery);
                        },
                        child: Container(
                          height: 80,
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.violet40,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.solidImage,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              Text(
                                "Galeria",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight(600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      child: DottedBorder(
        color: AppColors.light20,
        strokeWidth: 1,
        padding: EdgeInsets.symmetric(horizontal: 12),
        strokeCap: StrokeCap.round,
        dashPattern: [6],
        child: SizedBox(
          height: 55,
          width: double.infinity,
          child: Center(
            child: Row(
              spacing: 8,
              children: [
                FaIcon(FontAwesomeIcons.paperclip, color: AppColors.light20),
                Text(
                  "Adicionar anexo",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
