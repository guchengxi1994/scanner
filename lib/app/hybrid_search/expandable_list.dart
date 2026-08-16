import 'package:flutter/material.dart';
import 'package:scanner/app/hybrid_search/add_tag_button.dart';
import 'package:scanner/app/toast_utils.dart';

import 'search_item.dart';

class ExpandableList extends StatefulWidget {
  const ExpandableList({super.key});

  @override
  State<ExpandableList> createState() => ExpandableListState();
}

class ExpandableListState extends State<ExpandableList> {
  Set<String> include = {};
  Set<String> exculde = {};
  Set<String> startsWith = {};
  Set<String> endsWith = {};
  Set<String> regExp = {};

  (List<String>, List<String>, List<String>, List<String>, List<String>)
      getValues() {
    return (
      startsWith.toList(),
      endsWith.toList(),
      include.toList(),
      exculde.toList(),
      regExp.toList()
    );
  }

  List<String> getAll() {
    return [...include, ...exculde, ...startsWith, ...endsWith, ...regExp];
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 4,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: 500,
          padding: EdgeInsets.all(20),
          constraints: BoxConstraints(minHeight: 400, maxHeight: 600),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _wrapper(Row(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 30,
                      child: Text("包含:"),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...include.map((e) => SearchItem(
                              itemValue: e,
                              onDelete: (itemValue) {
                                include.remove(itemValue);
                                setState(() {});
                              },
                            )),
                        AddTagButton(onSave: (s) {
                          if (s.isEmpty) return;
                          setState(() {
                            include.add(s);
                          });
                        })
                      ],
                    )
                  ],
                )),
                SizedBox(
                  height: 20,
                ),
                _wrapper(Row(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 30,
                      child: Text("不包含:"),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...exculde.map((e) => SearchItem(
                              itemValue: e,
                              onDelete: (itemValue) {
                                exculde.remove(itemValue);
                                setState(() {});
                              },
                            )),
                        AddTagButton(onSave: (s) {
                          if (s.isEmpty) return;
                          setState(() {
                            exculde.add(s);
                          });
                        })
                      ],
                    )
                  ],
                )),
                SizedBox(
                  height: 20,
                ),
                _wrapper(Row(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 30,
                      child: Text("开头为:"),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...startsWith.map((e) => SearchItem(
                              itemValue: e,
                              onDelete: (itemValue) {
                                startsWith.remove(itemValue);
                                setState(() {});
                              },
                            )),
                        AddTagButton(onSave: (s) {
                          if (s.isEmpty) return;
                          setState(() {
                            startsWith.add(s);
                          });
                        })
                      ],
                    )
                  ],
                )),
                SizedBox(
                  height: 20,
                ),
                _wrapper(Row(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 30,
                      child: Text("结尾为:"),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...endsWith.map((e) => SearchItem(
                              itemValue: e,
                              onDelete: (itemValue) {
                                endsWith.remove(itemValue);
                                setState(() {});
                              },
                            )),
                        AddTagButton(onSave: (s) {
                          if (s.isEmpty) return;
                          setState(() {
                            endsWith.add(s);
                          });
                        })
                      ],
                    )
                  ],
                )),
                SizedBox(
                  height: 20,
                ),
                _wrapper(Row(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 30,
                      child: Text("正则:"),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...regExp.map((e) => SearchItem(
                              itemValue: e,
                              onDelete: (itemValue) {
                                regExp.remove(itemValue);
                                setState(() {});
                              },
                            )),
                        AddTagButton(onSave: (s) {
                          if (s.isEmpty) return;
                          if (!isValidRegExp(s)) {
                            ToastUtils.error(context, title: "错误的表达式");
                            return;
                          }
                          setState(() {
                            regExp.add(s);
                          });
                        })
                      ],
                    )
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _wrapper(Widget child) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(10),
      child: child,
    );
  }

  bool isValidRegExp(String pattern) {
    try {
      RegExp(pattern);
      return true; // 如果没有异常，说明正则有效
    } catch (e) {
      return false; // 捕获异常，说明正则无效
    }
  }
}
