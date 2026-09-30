import 'package:brasil_fields/brasil_fields.dart';
import 'package:dio/dio.dart';
import 'package:finance/core/services/util_service.dart';
import 'package:finance/core/theme/app_colors.dart';
import 'package:finance/core/widgets/primary_button.dart';
import 'package:finance/core/widgets/text_form_field_widget.dart';
import 'package:finance/core/widgets/toastify_widget.dart';
import 'package:finance/models/user.dart';
import 'package:finance/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.user});

  final User user;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _userRepository = UserRepository();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);

    String initialPhone = widget.user.phone;
    final digits = initialPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10 || digits.length == 11) {
      initialPhone = UtilBrasilFields.obterTelefone(digits);
    }
    _phoneController = TextEditingController(text: initialPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      await _userRepository.update({
        "id": widget.user.id,
        "name": _nameController.text,
        "email": _emailController.text,
        "phone": _phoneController.text,
      });

      if (mounted) {
        Toastfy.show(context, 'Perfil atualizado com sucesso!', 'success');
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
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: AppColors.light100,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            size: 18,
            color: AppColors.light80,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: AppColors.violet100,
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 40),
                child: const SizedBox.shrink(),
              ),
              Transform.translate(
                offset: const Offset(0, -30),
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
                          'Nome',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark75,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormFieldWidget(
                          controller: _nameController,
                          placeholder: 'Seu nome completo',
                          type: TextInputType.name,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'O nome é obrigatório';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'E-mail',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark75,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormFieldWidget(
                          controller: _emailController,
                          placeholder: 'Seu e-mail',
                          type: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'O e-mail é obrigatório';
                            }
                            final valid = RegExp(
                              r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(v);
                            if (!valid) return 'E-mail inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Telefone',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark75,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormFieldWidget(
                          controller: _phoneController,
                          placeholder: 'Seu telefone',
                          type: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            TelefoneInputFormatter(),
                          ],
                        ),
                        const SizedBox(height: 32),
                        PrimaryButton(
                          isLoading: _isLoading,
                          text: 'Salvar',
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
