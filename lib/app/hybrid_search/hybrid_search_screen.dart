import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:scanner/app/hybrid_search/expandable_list.dart';
import 'package:scanner/app/style.dart';
import 'package:scanner/src/rust/api/hybrid_search_api.dart';
import 'package:scanner/src/rust/hybrid_search.dart';

import 'hybrid_search_detail_widget.dart';

class HybridSearchScreen extends StatefulWidget {
  const HybridSearchScreen({super.key});

  @override
  State<HybridSearchScreen> createState() => _HybridSearchScreenState();
}

class _HybridSearchScreenState extends State<HybridSearchScreen> {
  bool isExpanded = false;
  final GlobalKey<ExpandableListState> key = GlobalKey<ExpandableListState>();
  final stream = searchStream();
  List<HybridSearchDetail> results = [];
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    stream.listen((event) {
      // print(event.path);
      setState(() {
        results.add(event);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (isExpanded) {
            setState(() {
              isExpanded = false;
            });
          }
        },
        child: Container(
          padding: EdgeInsets.all(20),
          color: Colors.transparent,
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                          controller: _controller,
                          enabled: true,
                          readOnly: true,
                          decoration: AppStyle.inputDecorationWithHintAndLabel(
                              "Please select a folder to scan", "Folder Path",
                              suffix: Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    setState(() {
                                      isExpanded = !isExpanded;
                                    });
                                  },
                                  child: Container(
                                    height: 40,
                                    padding: EdgeInsets.all(10),
                                    width: 100,
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.grey[300]!)),
                                    child: Center(
                                      child: Text("高级检索"),
                                    ),
                                  ),
                                ),
                              )),
                        )),
                        const SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              final String? directoryPath =
                                  await getDirectoryPath();
                              if (directoryPath == null) {
                                return;
                              }

                              _controller.text = directoryPath;
                            },
                            child: const Text("选择文件夹")),
                        const SizedBox(
                          width: 20,
                        ),
                        InkWell(
                          onTap: () {
                            if (_controller.text.isEmpty) {
                              return;
                            }
                            final v = key.currentState!.getValues();
                            if (v.$1.isEmpty &&
                                v.$2.isEmpty &&
                                v.$3.isEmpty &&
                                v.$4.isEmpty &&
                                v.$5.isEmpty) {
                              return;
                            }

                            hybridSearchStream(
                              p: _controller.text,
                              caseSensitive: false,
                              startsWith: v.$1,
                              endsWith: v.$2,
                              includes: v.$3,
                              excludes: v.$4,
                              regex: v.$5,
                              searchType: SearchType.and,
                            );
                          },
                          child: Icon(Icons.start),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                          children: results
                              .map((e) => HybridSearchDetailWidget(
                                    detail: e,
                                    find: key.currentState!.getAll(),
                                  ))
                              .toList()),
                    ),
                  )
                ],
              ),
              AnimatedPositioned(
                left: (MediaQuery.of(context).size.width - 500) / 2,
                top: !isExpanded ? -500 : 80,
                duration: Duration(milliseconds: 300),
                child: ExpandableList(
                  key: key,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
