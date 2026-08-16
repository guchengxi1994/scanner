import 'package:flutter/material.dart';

typedef OnDelete = void Function(String itemValue);

class SearchItem extends StatelessWidget {
  const SearchItem(
      {super.key, required this.itemValue, required this.onDelete});
  final String itemValue;
  final OnDelete onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(itemValue),
        InkWell(
          onTap: () {
            onDelete(itemValue);
          },
          child: Icon(
            Icons.delete,
            size: 20,
            color: Colors.redAccent,
          ),
        )
      ],
    );
  }
}
