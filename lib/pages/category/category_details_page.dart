import 'package:dio/dio.dart';
import 'package:finance/core/services/util_service.dart';
import 'package:finance/core/theme/app_colors.dart';
import 'package:finance/core/widgets/dropdown_widget.dart';
import 'package:finance/core/widgets/primary_button.dart';
import 'package:finance/core/widgets/text_form_field_widget.dart';
import 'package:finance/core/widgets/toastify_widget.dart';
import 'package:finance/models/category.dart';
import 'package:finance/repositories/category_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryDetailsPage extends StatefulWidget {
  const CategoryDetailsPage({super.key, this.category});

  final Category? category;

  @override
  State<CategoryDetailsPage> createState() => _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends State<CategoryDetailsPage> {
  final _categoryRepository = CategoryRepository();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _typeController;

  bool _isLoading = false;

  bool get isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? "");
    _typeController = TextEditingController(
      text: widget.category?.type ?? "expense",
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_typeController.text.isEmpty) {
      Toastfy.show(context, "O Tipo é obrigatório", "warning");
      return;
    }

    try {
      setState(() => _isLoading = true);

      final data = {
        if (isEditing) "id": widget.category!.id,
        "name": _nameController.text.trim(),
        "type": _typeController.text,
      };

      if (isEditing) {
        await _categoryRepository.update(data);
      } else {
        await _categoryRepository.create(data);
      }

      if (mounted) {
        Toastfy.show(
          context,
          isEditing
              ? "Categoria atualizada com sucesso!"
              : "Categoria criada com sucesso!",
          "success",
        );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Excluir Categoria",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.dark75,
          ),
        ),
        content: Text(
          "Tem certeza que deseja excluir a categoria \"${widget.category!.name}\"?",
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
      await _categoryRepository.delete(widget.category!.id);

      if (mounted) {
        Toastfy.show(context, "Categoria excluída com sucesso!", "success");
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
      backgroundColor: AppColors.light80,
      appBar: AppBar(
        backgroundColor: AppColors.violet100,
        foregroundColor: AppColors.light100,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isEditing ? "Editar Categoria" : "Nova Categoria",
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
        child: SingleChildScrollView(
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
                          "Nome",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark75,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormFieldWidget(
                          controller: _nameController,
                          placeholder: "Ex: Alimentação, Salário...",
                          type: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "O Nome é obrigatório";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Tipo",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark75,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownWidget(
                          controller: _typeController,
                          items: const [
                            DropdownMenuItem<String>(
                              value: "expense",
                              child: Text(
                                "Despesa",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: "income",
                              child: Text(
                                "Receita",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          placeholder: "Selecione o tipo",
                        ),
                        const SizedBox(height: 36),
                        PrimaryButton(
                          isLoading: _isLoading,
                          text: isEditing ? "Salvar Alterações" : "Criar Categoria",
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
