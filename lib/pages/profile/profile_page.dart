import 'package:dio/dio.dart';
import 'package:finance/core/providers/profile_provider.dart';
import 'package:finance/core/services/util_service.dart';
import 'package:finance/core/theme/app_colors.dart';
import 'package:finance/core/widgets/toastify_widget.dart';
import 'package:finance/models/user.dart';
import 'package:finance/pages/auth/login_page.dart';
import 'package:finance/pages/category/category_page.dart';
import 'package:finance/pages/profile/edit_profile_page.dart';
import 'package:finance/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _userRepository = UserRepository();

  User? _user;
  bool _isInitLoading = true;
  bool _isUpdatingPhoto = false;

  @override
  void initState() {
    super.initState();
    _initial();
  }

  Future<void> _initial() async {
    try {
      setState(() => _isInitLoading = true);
      await _loadUser();
    } finally {
      setState(() => _isInitLoading = false);
    }
  }

  Future<void> _loadUser() async {
    try {
      final user = await _userRepository.getMe();
      setState(() => _user = user);

      if (mounted) {
        ref.read(photoProfileUserProvider('smt_photo').notifier).state =
            user.photo;
      }
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    }
  }

  Future<void> _navigateToEdit() async {
    if (_user == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: _user!),
      ),
    );
    if (result == true) {
      await _loadUser();
    }
  }

  void _showPhotoOptionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final hasPhoto = _user?.photo.isNotEmpty == true;
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
                'Foto de Perfil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark75,
                ),
              ),
              const SizedBox(height: 20),
              _buildPhotoOptionItem(
                icon: FontAwesomeIcons.camera,
                iconColor: AppColors.violet100,
                bgColor: AppColors.violet20,
                title: 'Tirar foto',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadPhoto(ImageSource.camera);
                },
              ),
              const SizedBox(height: 12),
              _buildPhotoOptionItem(
                icon: FontAwesomeIcons.image,
                iconColor: AppColors.blue100,
                bgColor: AppColors.blue20,
                title: 'Escolher da galeria',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadPhoto(ImageSource.gallery);
                },
              ),
              if (hasPhoto) ...[
                const SizedBox(height: 12),
                _buildPhotoOptionItem(
                  icon: FontAwesomeIcons.trashCan,
                  iconColor: AppColors.red100,
                  bgColor: AppColors.red20,
                  title: 'Remover foto',
                  titleColor: AppColors.red100,
                  onTap: () {
                    Navigator.pop(ctx);
                    _removePhoto();
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoOptionItem({
    required FaIconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required VoidCallback onTap,
    Color titleColor = AppColors.dark75,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.light60,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: FaIcon(icon, color: iconColor, size: 16),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
            ),
            const FaIcon(
              FontAwesomeIcons.chevronRight,
              color: AppColors.dark25,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) return;

      setState(() => _isUpdatingPhoto = true);

      final newPhotoUrl = await _userRepository.updatePhoto(image.path);

      final box = Hive.box('auth');
      box.put('photo', newPhotoUrl);

      if (mounted) {
        ref.read(photoProfileUserProvider('smt_photo').notifier).state =
            newPhotoUrl;
        setState(() {
          if (_user != null) {
            _user = _user!.copyWith(photo: newPhotoUrl);
          }
        });
        Toastfy.show(
          context,
          'Foto de perfil atualizada com sucesso!',
          'success',
        );
      }
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    } catch (_) {
      if (mounted) {
        Toastfy.show(context, 'Falha ao selecionar foto', 'error');
      }
    } finally {
      if (mounted) setState(() => _isUpdatingPhoto = false);
    }
  }

  Future<void> _removePhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Remover Foto',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.dark75,
          ),
        ),
        content: const Text(
          'Tem certeza que deseja remover sua foto de perfil?',
          style: TextStyle(color: AppColors.dark25),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.dark25),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Remover',
              style: TextStyle(color: AppColors.red100),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() => _isUpdatingPhoto = true);

      await _userRepository.removePhoto();

      final box = Hive.box('auth');
      box.put('photo', '');

      if (mounted) {
        ref.read(photoProfileUserProvider('smt_photo').notifier).state = '';
        setState(() {
          if (_user != null) {
            _user = _user!.copyWith(photo: '');
          }
        });
        Toastfy.show(
          context,
          'Foto de perfil removida com sucesso!',
          'success',
        );
      }
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    } catch (_) {
      if (mounted) {
        Toastfy.show(context, 'Falha ao remover foto', 'error');
      }
    } finally {
      if (mounted) setState(() => _isUpdatingPhoto = false);
    }
  }

  void _navigateToCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CategoryPage()),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sair',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.dark75,
          ),
        ),
        content: const Text(
          'Tem certeza que deseja sair da sua conta?',
          style: TextStyle(color: AppColors.dark25),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.dark25),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final box = Hive.box('auth');
              await box.clear();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Sair',
              style: TextStyle(color: AppColors.red100),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light80,
      body: _isInitLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _initial,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 14),
                    _buildMenuSection(),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: AppColors.violet100,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Perfil',
                    style: TextStyle(
                      color: AppColors.light100,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const FaIcon(
                      FontAwesomeIcons.penToSquare,
                      color: AppColors.light100,
                      size: 18,
                    ),
                    onPressed: _navigateToEdit,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildAvatar(),
              const SizedBox(height: 16),
              Text(
                _user?.name ?? '',
                style: const TextStyle(
                  color: AppColors.light100,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _user?.email ?? '',
                style: TextStyle(
                  color: AppColors.light100.withValues(alpha: 0.75),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              if (_user?.phone.isNotEmpty == true)
                Text(
                  _user!.phone,
                  style: TextStyle(
                    color: AppColors.light100.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final photo = _user?.photo ?? '';
    return GestureDetector(
      onTap: _isUpdatingPhoto ? null : _showPhotoOptionsModal,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.light100, width: 3),
            ),
            child: ClipOval(
              child: _isUpdatingPhoto
                  ? Container(
                      color: AppColors.violet40,
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.light100,
                          ),
                        ),
                      ),
                    )
                  : photo.isNotEmpty
                      ? Image.network(
                          photo,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              _defaultAvatar(),
                        )
                      : _defaultAvatar(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.light100,
              shape: BoxShape.circle,
            ),
            child: const FaIcon(
              FontAwesomeIcons.camera,
              color: AppColors.violet100,
              size: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: AppColors.violet40,
      child: const Center(
        child: FaIcon(
          FontAwesomeIcons.user,
          color: AppColors.light100,
          size: 36,
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSectionLabel('Conta'),
          const SizedBox(height: 8),
          _buildMenuCard([
            _buildMenuItem(
              icon: FontAwesomeIcons.userPen,
              iconColor: AppColors.violet100,
              bgColor: AppColors.violet20,
              label: 'Editar Perfil',
              onTap: _navigateToEdit,
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: FontAwesomeIcons.tags,
              iconColor: AppColors.blue100,
              bgColor: AppColors.blue20,
              label: 'Categorias',
              onTap: _navigateToCategories,
            ),
          ]),
          const SizedBox(height: 20),
          _buildSectionLabel('Outros'),
          const SizedBox(height: 8),
          _buildMenuCard([
            _buildMenuItem(
              icon: FontAwesomeIcons.circleInfo,
              iconColor: AppColors.green100,
              bgColor: AppColors.green20,
              label: 'Sobre o App',
              onTap: _showAboutDialog,
            ),
          ]),
          const SizedBox(height: 20),
          _buildMenuCard([
            _buildMenuItem(
              icon: FontAwesomeIcons.rightFromBracket,
              iconColor: AppColors.red100,
              bgColor: AppColors.red20,
              label: 'Sair',
              labelColor: AppColors.red100,
              onTap: _logout,
              showArrow: false,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.dark25,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      width: double.infinity,
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
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required FaIconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required VoidCallback onTap,
    Color labelColor = AppColors.dark75,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: FaIcon(icon, color: iconColor, size: 18),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ),
            if (showArrow)
              const FaIcon(
                FontAwesomeIcons.chevronRight,
                color: AppColors.dark25,
                size: 14,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 74,
      endIndent: 16,
      color: AppColors.light20,
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'My Finances',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.dark75,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.violet20,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.wallet,
                  color: AppColors.violet100,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Controle suas finanças de forma simples e inteligente.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.dark25, fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Versão 1.0.0',
              style: TextStyle(
                color: AppColors.dark25,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Fechar',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
