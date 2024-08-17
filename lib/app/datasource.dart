import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:duplicate_finder/src/rust/scanner/compare_result.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class ScannerDatasource extends DataTableSource {
  final BuildContext context;
  late List<CompareResult> results;

  ScannerDatasource(this.context, this.results);

  @override
  DataRow2? getRow(int index) {
    return DataRow2(
      specificRowHeight: results[index].count.toDouble() * 50 + 16,
      cells: [
        DataCell(Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(results[index].index.toString()))),
        DataCell(Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(filesize(results[index].fileSize)))),
        DataCell(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: buildResult(results[index]),
          ),
        ),
      ],
    );
  }

  Widget buildResult(CompareResult result) {
    return ListView.builder(
        itemCount: result.allSameFiles.length,
        itemBuilder: (c, i) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Material(
                borderRadius: BorderRadius.circular(10),
                elevation: 10,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                      height: result.allSameFiles[i].length * 50,
                      child: Column(
                        children: result.allSameFiles[i]
                            .mapIndexed((i, v) => Tooltip(
                                  waitDuration: const Duration(seconds: 1),
                                  message: v.path,
                                  child: SizedBox(
                                    height: 50,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16, right: 16),
                                        child: Text("${i + 1}. ${v.name}"),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    if (result.allSameFiles[i].length > 1)
                      Positioned(
                        top: result.allSameFiles[i].length * 50 > 250
                            ? result.allSameFiles[i].length * 50 / 2 -
                                fontSize / 2
                            : 0,
                        right: 10,
                        child: Transform.rotate(
                          angle: -3.14 / 4,
                          child: SizedBox(
                            width: min(
                                250,
                                result.allSameFiles[i].length *
                                    50 * /* 根号2 */
                                    1.4),
                            child: AnimatedTextKit(animatedTexts: [
                              ColorizeAnimatedText(
                                'These files are the same',
                                textStyle: colorizeTextStyle,
                                colors: colorizeColors,
                              ),
                            ], isRepeatingAnimation: true, repeatForever: true),
                          ),
                        ),
                      )
                  ],
                )),
          );
        });
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => results.length;

  @override
  int get selectedRowCount => 0;
}

const fontSize = 20.0;

const colorizeColors = [
  Colors.purple,
  Colors.blue,
  Colors.yellow,
  Colors.red,
];

const colorizeTextStyle = TextStyle(
  fontSize: fontSize,
  fontFamily: 'Horizon',
);
