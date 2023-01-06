import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qntyController = TextEditingController();

  final box = Hive.box("cart_box");
  List<Map<String, dynamic>> _item = [];

  void _refreshItems() {
    final data = box.keys.map((e) {
      final item = box.get(e);
      return {"key": e, "name": item["name"], "quantity": item["quantity"]};
    }).toList();
    setState(() {
      _item = data.reversed.toList();
    });
  }

  Future<void> _createItem(Map<String, dynamic> item) async {
    await box.add(item);
    _refreshItems();
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await box.put(itemKey, item);
    _refreshItems();
  }

  Future<void> _deleteItem(int item) async {
    await box.delete(item);
    _refreshItems();

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Item has been Deleted")));
  }

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  void _showForm(BuildContext context, int? item) async {
    if (item != null) {
      final existingItem =
          _item.firstWhere((element) => element["key"] == item);
      _nameController.text = existingItem["name"];
      _qntyController.text = existingItem["quantity"];
    }
    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 15,
          left: 15,
          right: 15,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: "name"),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: _qntyController,
              decoration: const InputDecoration(hintText: "Quantity"),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () async {
                  if (item == null) {
                    _createItem({
                      "name": _nameController.text,
                      "quantity": _qntyController.text,
                    });
                  }
                  if (item != null) {
                    _updateItem(item, {
                      "name": _nameController.text,
                      "quantity": _qntyController.text,
                    });
                  }
                  _nameController.clear();
                  _qntyController.clear();
                  Navigator.pop(context);
                },
                child: Text(item == null ? "Create New" : "Update")),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Hive"),
      ),
      body: ListView.builder(
        itemCount: _item.length,
        itemBuilder: (context, index) {
          final currentItem = _item[index];
          return Card(
            color: Colors.white70,
            elevation: 5,
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(currentItem["name"]),
              subtitle: Text(currentItem["quantity"].toString()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: () {
                        _showForm(context, currentItem["key"]);
                      },
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () {
                        _deleteItem(currentItem["key"]);
                      },
                      icon: const Icon(Icons.delete))
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _showForm(context, null),
          child: const Icon(Icons.add)),
    );
  }
}
