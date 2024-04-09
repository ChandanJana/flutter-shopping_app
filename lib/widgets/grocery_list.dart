import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_app/data/categories.dart';
import 'package:shopping_app/models/grocery_item.dart';
import 'package:shopping_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _listGrocery = [];
  var _isLoading = true;
  String? _error;

  void _reload() {
    setState(() {
      _listGrocery.clear();
      _error = null;
      _isLoading = true;
    });
    _loadGrocery();
  }

  void _loadGrocery() async {
    /// Here we getting/fetch data to firebase
    final url = Uri.https(
        'flutter-prep-18dfc-default-rtdb.firebaseio.com', 'shopping_app.json');
    try{
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later!';
        });
      }
      print(response.body);
      /// if no data available in firebase then response will 'null'
      if(response.body == 'null'){
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final Map<String, dynamic> listGrocery = json.decode(response.body);
      print(listGrocery);
      List<GroceryItem> localList = [];
      for (final item in listGrocery.entries) {
        final category = categories.entries
            .firstWhere(
              (element) => element.value.title == item.value['category'],
        )
            .value;
        localList.add(GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category));
      }

      setState(() {
        _listGrocery = localList;
        _isLoading = false;
      });
    }catch(error){
      setState(() {
        //_isLoading = false;
        _error = 'Something went wrong';
      });

    }

  }

  void _addItem() async {
    final newData = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    setState(() {
      _listGrocery.add(newData!);
    });
    //_loadGrocery();
  }

  void _removeGrocery(GroceryItem item) async {
    final index = _listGrocery.indexOf(item);
    setState(() {
      _listGrocery.remove(item);
    });
    final url = Uri.https(
        'flutter-prep-18dfc-default-rtdb.firebaseio.com', 'shopping_app/${item.id}.json');
    final response = await http.delete(url);

    if(response.statusCode >= 400){
      setState(() {
        _listGrocery.insert(index, item);
      });
    }

  }

  @override
  void initState() {
    super.initState();
    _loadGrocery();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      alignment: Alignment.center,
      child: const Text('No Grocery available'),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
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

    if (_error != null) {
      content = Container(
        alignment: Alignment.center,
        child: Text(_error!),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery'),
        actions: [
          IconButton(
            onPressed: () {
              _addItem();
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {
              _reload();
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: content,
    );
  }
}
