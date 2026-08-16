import 'package:flutter/material.dart';
import 'package:scanner/src/rust/hybrid_search.dart';

import 'highlight.dart';

class HybridSearchDetailWidget extends StatelessWidget {
  const HybridSearchDetailWidget(
      {super.key, required this.detail, required this.find});
  final HybridSearchDetail detail;
  final List<String> find;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: EdgeInsets.all(10),
        height: 50,
        // margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.white.withOpacity(0.5),
        ),
        child: Row(
          children: [
            Text.rich(HighlightText.multiKeywords(detail.path, find,
                caseSensitive: false))
          ],
        ),
      ),
    );
  }
}
