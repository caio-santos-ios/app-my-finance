import 'package:dio/dio.dart';
import 'package:finance/core/services/auth_service.dart';
import 'package:finance/core/services/util_service.dart';
import 'package:finance/core/widgets/primary_button.dart';
import 'package:finance/core/widgets/text_form_field_widget.dart';
import 'package:finance/pages/auth/forgot_password_page.dart';
import 'package:finance/pages/auth/register_page.dart';
import 'package:finance/pages/main/main_page.dart';
import 'package:finance/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authRepository = AuthRepository();

  final _emailController = TextEditingController(text: "");
  final _passwordController = TextEditingController(text: "");

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  Future<void> _login() async {
    try {
      setState(() => _isLoading = true);

      final response = await _authRepository.login({
        "email": _emailController.text,
        "password": _passwordController.text,
      });

      AuthService.setToken(response);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainPage(initialPage: 0)),
          (route) => false,
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
      appBar: AppBar(title: Text("Login"), centerTitle: true),
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
          TextFormFieldWidget(
            controller: _passwordController,
            placeholder: "Senha",
            type: TextInputType.visiblePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'A senha é obrigatório';
              }

              if (value.length < 8) {
                return 'A senha deve ter no mínimo 8 caracteres';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          PrimaryButton(
            isLoading: _isLoading,
            text: "Entrar",
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await _login();
              }
            },
          ),
          SizedBox(height: 20),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
              );
            },
            child: Text(
              "Esqueceu sua senha?",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                fontWeight: FontWeight(600),
              ),
              softWrap: true,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 3,
            children: [
              Text(
                "Ainda não tem uma conta?",
                style: TextStyle(
                  // color: Theme.of(context).textTheme.headlineLarge?.color,
                  fontSize: Theme.of(context).textTheme.headlineLarge?.fontSize,
                  fontWeight: FontWeight(600),
                ),
                softWrap: true,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text(
                  "Cadastre-se",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: Theme.of(
                      context,
                    ).textTheme.headlineLarge?.fontSize,
                    fontWeight: FontWeight(600),
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
