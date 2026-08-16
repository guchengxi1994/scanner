import 'package:flutter/material.dart';

typedef OnSave = void Function(String);

class AddTagButton extends StatefulWidget {
  const AddTagButton({super.key, required this.onSave});
  final OnSave onSave;

  @override
  State<AddTagButton> createState() => _AddTagButtonState();
}

const double size = 20;

class _AddTagButtonState extends State<AddTagButton> {
  bool isActivate = false;
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: Colors.orange),
      child: FittedBox(
        child: !isActivate
            ? InkWell(
                onTap: () {
                  setState(() {
                    isActivate = !isActivate;
                  });
                },
                child: const Icon(
                  Icons.add,
                  size: size,
                ),
              )
            : SizedBox(
                width: 300,
                height: size,
                child: Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                      controller: controller,
                      maxLength: 20,
                      style: const TextStyle(fontSize: 12),
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          counterText: "",
                          hintStyle: TextStyle(fontSize: 12),
                          hintText: "Max length 20",
                          // fillColor: AppStyle.inputFillColor,
                          filled: true,
                          contentPadding:
                              EdgeInsets.only(left: 10, right: 10, bottom: 18),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange),
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                          )),
                    )),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      child: const Icon(
                        Icons.check,
                        size: size,
                      ),
                      onTap: () {
                        setState(() {
                          widget.onSave(controller.text);
                          isActivate = !isActivate;
                        });
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      child: const Icon(
                        Icons.refresh,
                        size: size,
                      ),
                      onTap: () {
                        controller.text = "";
                      },
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
