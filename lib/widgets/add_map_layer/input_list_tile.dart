import 'package:flutter/material.dart';
import 'package:mapify/providers/input_list_coordinates_provider.dart';
import 'package:mapify/widgets/add_map_layer/input_text_extra.dart';
import 'package:provider/provider.dart';

class InputListTile extends StatefulWidget {
  final int tileIndex;
  final String title;
  final Function(String) onSubmit;
  final Function onEditPressed;
  const InputListTile({
    super.key,
    required this.title,
    required this.onSubmit,
    required this.onEditPressed,
    required this.tileIndex,
  });

  @override
  _InputListTileState createState() => _InputListTileState();
}

class _InputListTileState extends State<InputListTile> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.title;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editingIndex = context
        .watch<InputListCoordinatesProvider>()
        .editingIndex;

    final isBeingEdited = editingIndex == widget.tileIndex;
    return ListTile(
      leading: Icon(Icons.location_on),
      title: InputTextExtra(
        isBeingEdited: isBeingEdited,
        controller: _controller,
        onSubmit: widget.onSubmit,
        title: widget.title,
      ),
      trailing: IconButton(
        icon: Icon(isBeingEdited ? Icons.check : Icons.edit),
        onPressed: () {
          setState(() {
            if (!isBeingEdited) {
              widget.onEditPressed();
            } else {
              widget.onSubmit(_controller.text);
            }
          });
        },
      ),
    );
  }
}
