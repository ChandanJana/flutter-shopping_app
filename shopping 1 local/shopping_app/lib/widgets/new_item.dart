import 'package:flutter/material.dart';
import 'package:shopping_app/data/categories.dart';
import 'package:shopping_app/models/category.dart';
import 'package:shopping_app/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NewItemSate();
  }
}

class _NewItemSate extends State<NewItem> {

  ///global key object that can be used as a value for a key as we need
  /// Now the difference between a global key and value key.
  /// a global key here then also gives us easy access to the underlying widget
  // to which it is connected And it ensures that if that build method here is executed
  /// again because we set some state for example, this form widget is not rebuilt
  /// and instead keeps its internal state,which is very important
  /// because it's that internal state with which will work in the end
  /// GlobalKey:
  /// Purpose: GlobalKey is used to identify and reference widgets when you need
  /// to access their state or properties directly or manipulate them from anywhere
  /// within the widget tree, regardless of their location in the hierarchy.
  /// ValueKey:
  /// Purpose: ValueKey is used to uniquely identify widgets in a specific
  /// context, primarily for widget rebuilding purposes. It's not intended for
  /// accessing or manipulating widget state but rather to help Flutter determine
  /// if a widget should be replaced during widget rebuilding.
  final _formKey = GlobalKey<FormState>();

  var _enteredName = '';
  var _enteredQty = 1;
  var _selectedCategory = categories[Categories.vegetables];

  void _saveItem() {
    /// validate, which is a method provided by the form widget in the end,
    /// which will automatically behind the scenes reach out
    /// to all the form field widgets inside of the form
    /// like text form field, and execute its validator functions, if everything is
    /// fine then it will return true otherwise false.
    if (_formKey.currentState!.validate()) {
      /// when calling the save method, a special function will be triggered
      /// on all these form field widgets inside the form, like this TextFormField.
      /// The special function that will be triggered is the onSaved function.
      /// So a function you pass to the onSaved parameter value.
      /// Now onSaved is a function that receives the value that was entered as an argument
      /// and this will be the value at the point of time save is executed.
      _formKey.currentState!.save();
      Navigator.of(context).pop(GroceryItem(
          id: DateTime.now().toString(),
          name: _enteredName,
          quantity: _enteredQty,
          category: _selectedCategory!));
    }
    print(_enteredName);
    print(_enteredQty);
    print(_selectedCategory);

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(label: Text('name')),
                validator: (value) {
                  /// return error message if validation failed
                  /// otherwise return null
                  ///
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text(
                          'Quantity',
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        /// return error message if validation failed
                        /// otherwise return null
                        /// int.tryParse use to convert to int
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be a valid positive number.';
                        }
                        return null;
                      },
                      initialValue: _enteredQty.toString(),
                      onSaved: (value) {
                        _enteredQty = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                    },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _saveItem,
                    child: const Text('Add'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
