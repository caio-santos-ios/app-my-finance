import 'package:dio/dio.dart';
import 'package:finance/core/services/util_service.dart';
import 'package:finance/core/theme/app_colors.dart';
import 'package:finance/core/widgets/dropdown_widget.dart';
import 'package:finance/core/widgets/primary_button.dart';
import 'package:finance/core/widgets/toastify_widget.dart';
import 'package:finance/models/bank.dart';
import 'package:finance/repositories/bank_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BankDetailsPage extends StatefulWidget {
  const BankDetailsPage({super.key, this.bank});

  final Bank? bank;

  @override
  State<BankDetailsPage> createState() => _BankDetailsPageState();
}

class _BankDetailsPageState extends State<BankDetailsPage> {
  final _bankRepository = BankRepository();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;

  bool _isInitLoading = true;
  bool _isLoading = false;
  List<Bank> _typeBanks = [];

  bool get isEditing => widget.bank != null;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.bank?.code ?? "");
    _initial();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _initial() async {
    try {
      setState(() => _isInitLoading = true);
      final response = await _bankRepository.getTypeBanks();
      setState(() => _typeBanks = response);
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    } finally {
      if (mounted) setState(() => _isInitLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_codeController.text.isEmpty) {
      Toastfy.show(context, "Selecione um banco", "warning");
      return;
    }

    final selectedType = _typeBanks.where(
      (b) => b.code == _codeController.text,
    );
    final bankName = selectedType.isNotEmpty
        ? selectedType.first.name
        : (widget.bank?.name ?? _codeController.text);

    try {
      setState(() => _isLoading = true);

      final data = {
        if (isEditing) "id": widget.bank!.id,
        "code": _codeController.text,
        "name": bankName,
      };

      if (isEditing) {
        await _bankRepository.update(data);
      } else {
        await _bankRepository.create(data);
      }

      if (mounted) {
        Toastfy.show(
          context,
          isEditing
              ? "Banco atualizado com sucesso!"
              : "Banco criado com sucesso!",
          "success",
        );
        Navigator.pop(context, true);
      }
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    if (!isEditing) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Excluir Banco",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.dark75,
          ),
        ),
        content: Text(
          "Tem certeza que deseja excluir o banco \"${widget.bank!.name}\"?",
          style: const TextStyle(color: AppColors.dark25),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: AppColors.dark25),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Excluir",
              style: TextStyle(color: AppColors.red100),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() => _isLoading = true);
      await _bankRepository.delete(widget.bank!.id);

      if (mounted) {
        Toastfy.show(context, "Banco excluído com sucesso!", "success");
        Navigator.pop(context, true);
      }
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: Text(
          isEditing ? "Editar Banco" : "Novo Banco",
          style: const TextStyle(
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
        actions: [
          if (isEditing)
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.trashCan,
                size: 18,
                color: AppColors.light100,
              ),
              onPressed: _isLoading ? null : _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: _isInitLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      color: AppColors.violet100,
                      width: double.infinity,
                      padding: const EdgeInsets.only(bottom: 36),
                      child: const SizedBox.shrink(),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -24),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.light100,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Banco",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dark75,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownWidget(
                                controller: _codeController,
                                items: _typeBanks.map((bank) {
                                  return DropdownMenuItem<String>(
                                    value: bank.code,
                                    child: Text(
                                      bank.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                placeholder: "Selecione o banco",
                              ),
                              const SizedBox(height: 36),
                              PrimaryButton(
                                isLoading: _isLoading,
                                text: isEditing
                                    ? "Salvar Alterações"
                                    : "Adicionar Banco",
                                onPressed: _save,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
