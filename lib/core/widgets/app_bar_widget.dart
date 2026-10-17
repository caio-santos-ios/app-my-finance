import 'package:finance/core/widgets/profile_photo_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final List<Widget>? leftActions;
  final List<Widget>? rightActions;
  final bool hasProfilePhoto;
  final bool hasIconNotification;

  const AppBarWidget({
    super.key,
    required this.titleText,
    this.leftActions,
    this.rightActions,
    this.hasProfilePhoto = true,
    this.hasIconNotification = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(titleText),
      centerTitle: true,
      leadingWidth: 80,
      leading: hasProfilePhoto
          ? Container(
              margin: EdgeInsets.only(left: 12),
              child: Row(children: [ProfilePhotoWidget()]),
            )
          : null,
      actions: [
        ...?leftActions,

        if (hasIconNotification)
          InkWell(
            child: FaIcon(
              FontAwesomeIcons.bell,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

        ...?rightActions,
      ],
      actionsPadding: EdgeInsets.only(right: 18),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
