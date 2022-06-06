import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:flutter/material.dart';

class EditableTile extends StatefulWidget {
  const EditableTile({
    Key? key,
    required this.lable,
    required this.keybordType,
    required this.onApplyChanges,
    required this.value,
    required this.disableEditing,
    this.status,
    this.onDeleteText,
    this.onDelete,
  }) : super(key: key);

  final String lable;
  final String value;
  final String? onDeleteText;
  final Future<FirestoreErrors?> Function(String newVal) onApplyChanges;
  final TextInputType keybordType;
  final bool disableEditing;
  final Future<FirestoreErrors?> Function()? onDelete;
  final bool? status;

  @override
  State<EditableTile> createState() => _EditableTileState();
}

class _EditableTileState extends State<EditableTile> {
  var editMode = false;
  var loading = false;
  var deleting = false;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (loading) return loadingWidget();
    if (deleting) return const SizedBox();
    if (widget.disableEditing || !editMode) return defaultWidget();
    return editWidget();
  }

  ListTile loadingWidget() {
    return ListTile(
      title: deleting
          ? const Text("Deleting...")
          : const Text("Applying Changes..."),
      subtitle: Text(widget.lable),
      trailing: const CircularProgressIndicator(),
    );
  }

  ListTile editWidget() {
    return ListTile(
      title: TextField(
        autofocus: true,
        controller: controller,
        keyboardType: widget.keybordType,
        decoration: InputDecoration(
          prefixIcon: GestureDetector(
            onTap: () {
              setState(() {
                editMode = false;
                deleting = false;
              });
            },
            child: const Icon(Icons.cancel),
          ),
          suffixIcon: TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;
              if (newName == widget.value) {
                return setState(() {
                  editMode = false;
                  deleting = false;
                });
              }
              setState(() {
                loading = true;
                deleting = false;
              });
              final res = await widget.onApplyChanges(newName);
              if (mounted) {
                setState(() {
                  loading = false;
                  editMode = false;
                  deleting = false;
                });
                res?.showAlertDialog(context: context);
              }
            },
            child: const Icon(Icons.check),
          ),
          border: const OutlineInputBorder(),
          labelText: widget.lable,
        ),
      ),
    );
  }

  ListTile defaultWidget() {
    return ListTile(
      leading: widget.onDelete == null || widget.disableEditing
          ? null
          : TextButton(
              onPressed: () async {
                if (!await proceed(
                  context,
                  "Are You Sure To Remove",
                  widget.onDeleteText ??
                      "Warning, once deleted can't be undone!",
                )) return;
                setState(() {
                  loading = true;
                  deleting = true;
                  editMode = false;
                });
                final res = await widget.onDelete?.call();
                if (mounted) {
                  setState(() {
                    loading = false;
                    editMode = false;
                    if (res != null) deleting = false;
                  });
                  res?.showAlertDialog(context: context);
                }
              },
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
            ),
      title: Text(
        widget.lable,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? widget.status == true
                  ? Colors.greenAccent
                  : widget.status == false
                      ? Colors.redAccent
                      : null
              : widget.status == true
                  ? Colors.green
                  : widget.status == false
                      ? Colors.red
                      : null,
        ),
      ),
      subtitle: Text(widget.value),
      trailing: widget.disableEditing
          ? null
          : TextButton(
              child: const Icon(Icons.edit_outlined),
              onPressed: () {
                setState(() {
                  editMode = true;
                  controller = TextEditingController(text: widget.value);
                });
              }),
    );
  }
}
