import 'package:dio/dio.dart';
import 'package:finance/core/services/util_service.dart';
import 'package:finance/core/widgets/primary_button.dart';
import 'package:finance/core/widgets/text_form_field_widget.dart';
import 'package:finance/core/widgets/toastify_widget.dart';
import 'package:finance/pages/auth/login_page.dart';
import 'package:finance/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _authRepository = AuthRepository();

  final _emailController = TextEditingController(text: "");

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  Future<void> _forgotPassword() async {
    try {
      setState(() => _isLoading = true);

      final response = await _authRepository.forgotPassword({
        "email": _emailController.text,
      });

      if (mounted) {
        Toastfy.show(context, response.message, "success");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
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
      appBar: AppBar(title: Text("Esqueceu sua senha"), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.all(18),
          child: SingleChildScrollView(
            child: Column(children: [SizedBox(height: 40), _buildForm()]),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text(
            "Não se preocupe. Insira seu e-mail e enviaremos um link para redefinir sua senha.",
            style: Theme.of(context).textTheme.titleLarge,
            softWrap: true,
          ),
          SizedBox(height: 60),
          TextFormFieldWidget(
            controller: _emailController,
            placeholder: "E-mail",
            type: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'O e-mail é obrigatório';
              }

              final bool emailValid = RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
              ).hasMatch(value);

              if (!emailValid) {
                return 'O e-mail é inválido';
              }
              return null;
            },
          ),
          SizedBox(height: 18),
          PrimaryButton(
            isLoading: _isLoading,
            text: "Continuar",
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await _forgotPassword();
              }
            },
          ),
        ],
      ),
    );
  }
}
