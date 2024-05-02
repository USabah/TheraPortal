import 'package:flutter/material.dart';
import 'package:theraportal/Widgets/Styles.dart';

class AccountReferenceCodeBlock extends StatelessWidget {
  final String character;

  const AccountReferenceCodeBlock({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Styles.beige),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        character.toUpperCase(),
        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    );
  }
}
