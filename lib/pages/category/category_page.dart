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

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final _categoryRepository = CategoryRepository();

  final _nameController = TextEditingController(text: "");
  final _typeController = TextEditingController(text: "");

  bool _isLoading = false;
  bool _isInitLoading = true;

  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _initial();
  }

  Future<void> _initial() async {
    setState(() => _isInitLoading = true);
    await _getCategories();
    setState(() => _isInitLoading = false);
  }

  Future<void> _getCategories() async {
    // try {
    //   final response = await _categoryRepository.getSelect();
    //   setState(() {
    //     _categories = response;
    //   });
    // } on DioException catch (err) {
    //   if (mounted) UtilService.normalizeError(context, err);
    // }
  }

  Future<void> _save() async {
    try {
      setState(() => _isLoading = true);
      final data = {
        "name": _nameController.text,
        "type": _typeController.text,
      };

      final response = await _categoryRepository.create(data);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Categoria")),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: RefreshIndicator(
                    onRefresh: () async {},
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (_isInitLoading)
                          const Center(child: CircularProgressIndicator()),

                        if (!_isInitLoading) ...[
                          const SizedBox(height: 45),
                          _buildStandardForm(),
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

  Widget _buildStandardForm() {
    return Column(
      children: [
        const SizedBox(height: 14),
        TextFormFieldWidget(
          controller: _nameController,
          placeholder: "Nome",
          type: TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'O Nome é obrigatório';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        DropdownWidget(
          controller: _typeController,
          items: ["income", "expense"]
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(e == "income" ? "Receita" : "Despesa", overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          placeholder: "Tipo",
        ),
        const SizedBox(height: 40),
        PrimaryButton(
          isLoading: _isLoading,
          text: "Salvar",
          onPressed: () async {
            await _save();
          },
        ),
      ],
    );
  }
}
