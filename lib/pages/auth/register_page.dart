import 'package:dio/dio.dart';
import 'package:finance/core/services/util_service.dart';
import 'package:finance/core/theme/app_colors.dart';
import 'package:finance/core/widgets/primary_button.dart';
import 'package:finance/core/widgets/text_form_field_widget.dart';
import 'package:finance/core/widgets/toastify_widget.dart';
import 'package:finance/pages/auth/confirmation_page.dart';
import 'package:finance/pages/auth/login_page.dart';
import 'package:finance/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _authRepository = AuthRepository();

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(text: "");
  final _emailController = TextEditingController(text: "");
  final _passwordController = TextEditingController(text: "");
  bool _termsOfService = false;

  bool _isLoading = false;

  Future<void> _register() async {
    try {
      setState(() => _isLoading = true);

      final response = await _authRepository.register({
        "name": _nameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
      });

      if (mounted) {
        Toastfy.show(context, response.message, "success");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ConfirmationPage(email: _emailController.text),
          ),
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
      appBar: AppBar(title: Text("Inscrever-se"), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.all(18),
          child: SingleChildScrollView(
            child: Column(children: [SizedBox(height: 50), _buildForm()]),
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
            controller: _nameController,
            placeholder: "Nome",
            type: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'O nome é obrigatório';
              }
              return null;
            },
          ),
          SizedBox(height: 15),
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
          SizedBox(height: 15),
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
          SizedBox(height: 15),
          FormField<bool>(
            initialValue: _termsOfService,
            validator: (value) {
              if (value != true) {
                return 'Você precisa aceitar os termos de serviço';
              }
              return null;
            },
            builder: (state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _termsOfService,
                        onChanged: (v) {
                          setState(() {
                            _termsOfService = v!;
                          });
                          state.didChange(v);
                        },
                      ),
                      Expanded(
                        child: Text(
                          "Ao se cadastrar, você concorda com os termos de serviço e política de privacidade",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                            fontSize: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.fontSize,
                            fontWeight: FontWeight(600),
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        state.errorText!,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              );
            },
          ),
          SizedBox(height: 15),
          PrimaryButton(
            isLoading: _isLoading,
            text: "Inscrever-se",
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await _register();
              }
            },
          ),
          SizedBox(height: 15),
          Text(
            "Ou com",
            style: Theme.of(context).textTheme.headlineMedium,
            softWrap: true,
          ),
          SizedBox(height: 15),
          _buildButtonGoogle(),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 3,
            children: [
              Text(
                "Já tem uma conta?",
                style: TextStyle(
                  color: Theme.of(context).textTheme.headlineLarge?.color,
                  fontSize: Theme.of(context).textTheme.headlineLarge?.fontSize,
                  fontWeight: FontWeight(600),
                ),
                softWrap: true,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text(
                  "Login",
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

  Widget _buildButtonGoogle() {
    return TextButton(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.light20, width: 1),
        ),
      ),
      onPressed: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 6,
        children: [
          Image.asset("assets/icons/icon-google.png"),
          Text(
            "Cadastre-se com o Google",
            style: Theme.of(context).textTheme.titleSmall,
            softWrap: true,
          ),
        ],
      ),
    );
  }
}
