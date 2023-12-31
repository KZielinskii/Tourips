
import 'package:flutter/material.dart';

import '../../../models/UserModel.dart';

class RequestListItemView extends StatelessWidget {
  final ImageProvider image;
  final String buttonFirstText;
  final String buttonSecondText;
  final VoidCallback onPressedFirst;
  final VoidCallback onPressedSecond;
  final UserModel user;

  const RequestListItemView({
    super.key,
    required this.image,
    required this.buttonFirstText,
    required this.buttonSecondText,
    required this.onPressedFirst,
    required this.onPressedSecond,
    required this.user,
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
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: onPressedFirst,
                  icon: const Icon(Icons.person_add_alt_rounded, color: Colors.green,),
                  label: Text(buttonFirstText),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: onPressedSecond,
                  icon: const Icon(Icons.delete_forever, color: Colors.red,),
                  label: Text(buttonSecondText),
                ),
              ]
            )
          ],
        ),
      ),
    );
  }
}