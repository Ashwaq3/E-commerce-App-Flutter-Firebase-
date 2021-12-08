import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youcan/providers/product.dart';
import 'package:youcan/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Product _editedProduct =
      Product(title: '', description: '', imageUrl: '', price: 0, id: '');

  var _initialValue = {
    "title": '',
    "description": '',
    "imageUrl": '',
    "price": '',
  };

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments;
      if (productId != null) {
        _editedProduct = Provider.of<Products>(context, listen: false)
            .findById(productId.toString());
        _initialValue = {
          "title": _editedProduct.title,
          "description": _editedProduct.description,
          "imageUrl": '',
          "price": _editedProduct.price.toString(),
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    _priceFocusNode.dispose();
    descriptionFocusNode.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != '') {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (e) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text('An error occurred!'),
                  content: const Text('Something went wrong.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Okay!'))
                  ],
                ));
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(onPressed: _saveForm, icon: const Icon(Icons.save))
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initialValue["title"],
                      decoration: const InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      //related to focusScope "when pressed it goes to the next field"
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please provide a value';
                        }
                        return null;
                      },
                      onSaved: (val) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            title: val!,
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            price: _editedProduct.price);
                      },
                    ),
                    TextFormField(
                      initialValue: _initialValue["price"],
                      decoration: const InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      //related to focusScope "when pressed it goes to the next field"
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(descriptionFocusNode);
                      },
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please provide a price';
                        }
                        if (double.tryParse(val) == null) {
                          return 'Please provide a valid price';
                        }
                        if (double.parse(val) <= 0) {
                          return 'Please provide a price greater than zero';
                        }
                        return null;
                      },
                      onSaved: (val) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            price: double.parse(val!));
                      },
                    ),
                    TextFormField(
                      initialValue: _initialValue["description"],
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      focusNode: descriptionFocusNode,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please provide a description';
                        }
                        if (val.length < 10) {
                          return 'Should be at least 10 characters';
                        }
                        return null;
                      },
                      onSaved: (val) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: val!,
                            imageUrl: _editedProduct.imageUrl,
                            price: _editedProduct.price);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey)),
                          child: _imageUrlController.text.isEmpty
                              ? const Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _imageUrlController,
                            decoration:
                                const InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            focusNode: _imageUrlFocusNode,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please provide image URL';
                              }
                              if (!val.startsWith('http') &&
                                  !val.startsWith('https')) {
                                return 'Please provide a valid URL';
                              }
                              if (!val.endsWith('.png') &&
                                  !val.endsWith('.jpg') &&
                                  !val.endsWith('.jpeg')) {
                                return 'Please provide a valid URL';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _editedProduct = Product(
                                  id: _editedProduct.id,
                                  title: _editedProduct.title,
                                  description: _editedProduct.description,
                                  imageUrl: val!,
                                  price: _editedProduct.price);
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
