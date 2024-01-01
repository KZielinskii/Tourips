
import 'package:flutter/material.dart';

import '../../../../models/UserModel.dart';

class UserListItemView extends StatelessWidget {
  final ImageProvider image;
  final String buttonText;
  final VoidCallback onPressed;
  final UserModel user;
  final bool isButtonEnabled;

  const UserListItemView({
    super.key,
    required this.image,
    required this.buttonText,
    required this.onPressed,
    required this.user,
    required this.isButtonEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: image,
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                user.login,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: isButtonEnabled ? onPressed : null,
              icon: const Icon(Icons.person_add),
              label: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}