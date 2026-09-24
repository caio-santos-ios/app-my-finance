import 'package:finance/core/providers/profile_provider.dart';
import 'package:finance/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePhotoWidget extends ConsumerStatefulWidget {
  const ProfilePhotoWidget({
    super.key,
    this.width = 50,
    this.height = 50,
    this.sizeIcon = 25,
    this.hasSwitchTheme = true,
  });

  final double width;
  final double height;
  final double sizeIcon;
  final bool hasSwitchTheme;

  @override
  ConsumerState<ProfilePhotoWidget> createState() => _ProfilePhotoWidgetState();
}

class _ProfilePhotoWidgetState extends ConsumerState<ProfilePhotoWidget> {
  // final _smartService = SmartService();

  String userName = "";
  String? selectedCompany;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onInit();
    });
  }

  void onInit() {
    // ref.read(photoProfileUserProvider("smt_photo").notifier).state =
    //     _smartService.getUserPhoto();

    // String localThemeMode = _smartService.smtLocal.get("smt_theme_mode") ?? "light";
    // ref.read(themeModeProvider("smt_theme_mode").notifier).state =
    //     localThemeMode;
  }

  @override
  Widget build(BuildContext context) {
    final String photo = ref.watch(photoProfileUserProvider("smt_photo"));

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(5),
          width: widget.width,
          height: widget.height,
          child: photo.isEmpty
              ? Container(
                  padding: EdgeInsets.all(1),
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: CircleAvatar(
                    backgroundColor: AppColors.light100,
                    child: FaIcon(
                      FontAwesomeIcons.user,
                      color: Theme.of(context).colorScheme.primary,
                      size: widget.sizeIcon,
                    ),
                  ),
                )
              : CircleAvatar(backgroundImage: NetworkImage(photo)),
        ),
      ],
    );
  }
}
