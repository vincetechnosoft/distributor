import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:flutter/material.dart';

int controllerToInt(TextEditingController controller) {
  var val = controller.text;
  val = val.replaceAll(",", "").replaceAll(" ", "");
  return ((double.tryParse(val) ?? 0) * 1000).toInt();
}

class InventoryProductController {
  final quntity = TextEditingController();
  final pack = TextEditingController();
  final Product product;

  int get intQ => controllerToInt(quntity);
  int get intP => controllerToInt(pack);

  InventoryProductController(this.product);
}

class InputQuntity extends StatelessWidget {
  const InputQuntity(this.controller, {Key? key, required this.loading})
      : super(key: key);
  final InventoryProductController controller;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final pckInBox = controller.product.pckInBox;
    return Row(
      children: [
        Flexible(
          child: TextField(
            readOnly: loading,
            controller: controller.quntity,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: controller.product.name,
              suffix: GestureDetector(
                onTap: () {
                  controller.quntity.text = "";
                },
                child: const Icon(Icons.clear),
              ),
            ),
          ),
        ),
        if (pckInBox != null) ...[
          const SizedBox(width: 10),
          Flexible(
            child: TextField(
              readOnly: loading,
              controller: controller.pack,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Max Pck. = ${pckInBox.quntity / 1000}",
                suffix: GestureDetector(
                  onTap: () {
                    controller.pack.text = "";
                  },
                  child: const Icon(Icons.clear),
                ),
              ),
            ),
          )
        ],
      ],
    );
  }
}
