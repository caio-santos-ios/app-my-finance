import 'dart:async';

import 'package:dio/dio.dart';
import 'package:finance/core/services/util_service.dart';
import 'package:finance/core/widgets/primary_button.dart';
import 'package:finance/core/widgets/toastify_widget.dart';
import 'package:finance/pages/auth/login_page.dart';
import 'package:finance/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class ConfirmationPage extends StatefulWidget {
  const ConfirmationPage({super.key, required this.email});

  final String email;

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  final _authRepository = AuthRepository();

  final _formKey = GlobalKey<FormState>();

  final _codeController = TextEditingController(text: "");

  bool _isLoading = false;
  Timer? _pollTimer;
  int minutes = 300;

  @override
  void initState() {
    super.initState();

    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          minutes--;
        });
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _confirmation(String code) async {
    try {
      setState(() => _isLoading = true);

      final response = await _authRepository.confirmation({
        "code": code,
        "email": widget.email,
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

  Future<void> _resendCode() async {
    try {
      setState(() {
        minutes = 300;
      });

      final response = await _authRepository.newCode({"email": widget.email});

      if (mounted) {
        Toastfy.show(context, response.message, "success");
      }
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    }
  }

  String hashEmail(String email) {
    List<String> emails = email.split("@");

    int count = (emails[0].length / 2).toInt();

    String caracters = "";
    for (int i = 0; i < count; i++) {
      caracters += "*";
    }

    return "${emails[0].substring(0, count)}$caracters@${emails[1]}";
  }

  String toHourString(int totalMinutes) {
    if (totalMinutes < 0) totalMinutes = 0;

    double hours = totalMinutes.floor() / 60;
    double minutes = totalMinutes % 60;
    return "${hours.toInt().toString().padLeft(2, '0')}:${minutes.toInt().toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verificação"), centerTitle: true),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Insira seu código de verificação",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                            fontSize: Theme.of(
                              context,
                            ).textTheme.titleLarge?.fontSize,
                            fontWeight: FontWeight(600),
                          ),
                          softWrap: true,
                        ),
                        SizedBox(height: 40),
                        _buildForm(),
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

  Widget _buildForm() {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Pinput(
            defaultPinTheme: defaultPinTheme,
            length: 6,
            onCompleted: (pin) async {
              _codeController.text = pin;
              await _confirmation(pin);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                Toastfy.show(context, "O código é obrigatório", "warning");
                return;
              }
              return null;
            },
          ),
          SizedBox(height: 40),
          Row(
            children: [
              Text(
                toHourString(minutes),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight(600),
                ),
                softWrap: true,
              ),
            ],
          ),
          SizedBox(height: 15),
          Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              children: [
                const TextSpan(
                  text: "Enviamos um código de verificação para o seu e-mail ",
                ),
                TextSpan(
                  text: hashEmail(widget.email),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const TextSpan(
                  text: ". Você pode verificar sua caixa de entrada.",
                ),
              ],
            ),
          ),
          if (minutes == 0) ...[
            SizedBox(height: 15),
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    await _resendCode();
                  },
                  child: Text(
                    "Não recebi o código. Pode enviar novamente?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 15,
                      fontWeight: FontWeight(600),
                    ),
                    softWrap: true,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 40),
          PrimaryButton(
            isLoading: _isLoading,
            text: "Verificar",
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await _confirmation(_codeController.text);
              }
            },
          ),
        ],
      ),
    );
  }
}
