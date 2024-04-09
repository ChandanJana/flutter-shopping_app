import 'package:flutter/material.dart';
import 'package:shopping_app/models/grocery_item.dart';
import 'package:shopping_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _listGrocery = [];

  void _addItem() async {
    final newGrocery = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => NewItem(),
      ),
    );
    if (newGrocery == null) {
      return;
    }
    setState(() {
      _listGrocery.add(newGrocery);
    });
  }

  void _removeGrocery(GroceryItem item) {
    setState(() {
      _listGrocery.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      alignment: Alignment.center,
      child: const Text('No Grocery available'),
    );
    if (_listGrocery.isNotEmpty) {
      content = ListView.builder(
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_listGrocery[index].id),
          onDismissed: (direction) {
            _removeGrocery(_listGrocery[index]);
          },
          child: ListTile(
            title: Text(
              _listGrocery[index].name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Theme.of(context).colorScheme.onBackground),
            ),
            leading: Container(
              width: 24,
              height: 24,
              color: _listGrocery[index].category.color,
            ),
            trailing: Text(_listGrocery[index].quantity.toString()),
          ),
        ),
        itemCount: _listGrocery.length,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Grocery'),
        actions: [
          IconButton(
              onPressed: () {
                _addItem();
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: content,
    );
  }
}
