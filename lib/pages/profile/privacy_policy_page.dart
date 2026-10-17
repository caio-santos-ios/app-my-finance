import 'package:flutter/material.dart';
import 'package:finance/core/theme/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light80,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.dark75),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Política de Privacidade',
          style: TextStyle(
            color: AppColors.dark75,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.light100,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Política de Privacidade - Minhas Finanças',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark75,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Última atualização: Outubro de 2026',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.dark25,
                ),
              ),
              const Divider(height: 32, color: AppColors.light20),
              _buildSection(
                '1. Visão Geral',
                'O aplicativo Minhas Finanças foi desenvolvido para oferecer uma experiência simples, segura e eficiente de controle financeiro pessoal. A privacidade e a segurança das suas informações são prioridades absolutas. Esta Política de Privacidade descreve detalhadamente como coletamos, utilizamos, armazenamos e protegemos seus dados.',
              ),
              _buildSection(
                '2. Informações que Coletamos',
                'Para o correto funcionamento do aplicativo e prestação dos serviços, coletamos exclusivamente as seguintes informações:\n\n'
                '• Dados Cadastrais: Nome, endereço de e-mail e senha criptografada (hash seguro) para criação e autenticação de sua conta.\n'
                '• Dados Financeiros Pessoais: Lançamentos de receitas e despesas, valores, datas, descrições, categorias e orçamentos cadastrados voluntariamente por você.\n'
                '• Foto de Perfil (Opcional): Imagem selecionada por você na galeria para personalização da interface.',
              ),
              _buildSection(
                '3. Como Utilizamos Suas Informações',
                'Seus dados são utilizados exclusivamente para:\n\n'
                '• Permitir o acesso seguro à sua conta através de autenticação via Token JWT.\n'
                '• Armazenar e sincronizar suas transações financeiras para consulta em tempo real e visualização de dashboards.\n'
                '• Enviar e-mails de recuperação de senha ou notificações essenciais de segurança.\n\n'
                'Nenhum dado é utilizado para fins publicitários ou perfis de consumo.',
              ),
              _buildSection(
                '4. Compartilhamento e Venda de Dados',
                'NÃO vendemos, alugamos, comercializamos nem compartilhamos seus dados pessoais ou transações financeiras com terceiros ou redes de publicidade sob nenhuma hipótese.\n\n'
                'Seus dados só poderão ser divulgados em caso de determinação judicial ou legal obrigatória nos termos da legislação brasileira vigente.',
              ),
              _buildSection(
                '5. Segurança das Informações',
                'Adotamos práticas e padrões rigorosos de segurança técnica e organizacional:\n\n'
                '• Comunicação Criptografada: Todo o tráfego entre o aplicativo e os servidores é criptografado utilizando protocolo HTTPS com certificados SSL/TLS modernos.\n'
                '• Armazenamento Seguro: Senhas são processadas com algoritmos de hash criptográfico de via única (BCrypt).\n'
                '• Infraestrutura Segura: Banco de dados com autenticação restrita em ambiente isolado.',
              ),
              _buildSection(
                '6. Direitos do Usuário e LGPD',
                'Em total conformidade com a Lei Geral de Proteção de Dados (LGPD - Lei nº 13.709/2018), você possui o direito de:\n\n'
                '• Acessar e consultar todos os seus dados e transações cadastradas a qualquer momento.\n'
                '• Corrigir ou atualizar dados incompletos ou inexatos através da edição de perfil.\n'
                '• Solicitar a exclusão definitiva da sua conta e de todas as transações vinculadas diretamente pelo suporte.',
              ),
              _buildSection(
                '7. Contato e Encarregado',
                'Em caso de dúvidas, solicitações de esclarecimentos ou requisições sobre o tratamento dos seus dados pessoais, entre em contato diretamente pelo e-mail:\n\n'
                'caiosantos.dev@outlook.com',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.dark75,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.dark50,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
