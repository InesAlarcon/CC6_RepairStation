import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:repair_station/models/product.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ProductFormScreen extends StatelessWidget {
  final RepairProduct product;
  const ProductFormScreen({required this.product, super.key});

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        "Formulario de Producto",
        style: Theme.of(context).textTheme.headline2,
      ),
      centerTitle: true,
      // leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
    ),
    body: ProductForm(
      product: product,
    ),
  );
}
}

class ProductForm extends StatefulWidget {
  final RepairProduct product;
  const ProductForm({required this.product, super.key});

@override
ProductFormState createState() => ProductFormState();
}

class ProductFormState extends State<ProductForm> {
  bool autoValidate = true;
  bool _nameHasError = false,
      _priceHasError = false,
      _weightHasError = false,
      _stockHasError = false,
      _descriptionHasError = false,
      _yearHasError = false;
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              FormBuilder(
                key: _formKey,
                // enabled: false,
                onChanged: () {
                  _formKey.currentState!.save();
                  debugPrint(_formKey.currentState!.value.toString());
                },
                autovalidateMode: AutovalidateMode.always,
                initialValue: {
                  'name': widget.product.name,
                  'articleId': widget.product.articleId,
                  'price': widget.product.price.toStringAsFixed(2),
                  'weight': widget.product.weight.toStringAsFixed(2),
                  'stock': widget.product.stock.toString(),
                  'description': widget.product.description,
                  "year": widget.product.year.toString(),
                  "brand": widget.product.brand,
                  "model": widget.product.model,
                  "station": widget.product.station,
                },
                skipDisabled: true,
                child: Card(
                  elevation: 8.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        FormBuilderTextField(
                          name: 'articleId',
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Código',
                            suffixIcon: Icon(Icons.lock, color: Colors.green),
                          ),
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        FormBuilderTextField(
                          name: 'name',
                          decoration: InputDecoration(
                            labelText: 'Nombre Producto',
                            suffixIcon: _nameHasError
                                ? const Icon(Icons.error, color: Colors.red)
                                : const Icon(Icons.check, color: Colors.green),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _nameHasError = !(_formKey
                                  .currentState?.fields['name']
                                  ?.validate() ??
                                  false);
                            });
                          },
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        FormBuilderTextField(
                          name: 'price',
                          decoration: InputDecoration(
                            labelText: 'Precio (Q)',
                            suffixIcon: _priceHasError
                                ? const Icon(Icons.error, color: Colors.red)
                                : const Icon(Icons.check, color: Colors.green),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _priceHasError = !(_formKey
                                  .currentState?.fields['price']
                                  ?.validate() ??
                                  false);
                            });
                          },
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                            FormBuilderValidators.min(0),
                          ]),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        FormBuilderTextField(
                          name: 'weight',
                          decoration: InputDecoration(
                            labelText: 'Peso (Kq)',
                            suffixIcon: _weightHasError
                                ? const Icon(Icons.error, color: Colors.red)
                                : const Icon(Icons.check, color: Colors.green),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _weightHasError = !(_formKey
                                  .currentState?.fields['weight']
                                  ?.validate() ??
                                  false);
                            });
                          },
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                            FormBuilderValidators.min(0),
                          ]),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        FormBuilderTextField(
                          name: 'stock',
                          decoration: InputDecoration(
                            labelText: 'Stock',
                            suffixIcon: _stockHasError
                                ? const Icon(Icons.error, color: Colors.red)
                                : const Icon(Icons.check, color: Colors.green),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _stockHasError = !(_formKey
                                  .currentState?.fields['stock']
                                  ?.validate() ??
                                  false);
                            });
                          },
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                            FormBuilderValidators.min(0),
                          ]),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        FormBuilderTextField(
                          name: 'description',
                          decoration: InputDecoration(
                            labelText: 'Descripción',
                            suffixIcon: _descriptionHasError
                                ? const Icon(Icons.error, color: Colors.red)
                                : const Icon(Icons.check, color: Colors.green),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _descriptionHasError = !(_formKey
                                  .currentState?.fields['description']
                                  ?.validate() ??
                                  false);
                            });
                          },
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        FormBuilderTextField(
                          name: 'year',
                          decoration: InputDecoration(
                            labelText: 'Year',
                            suffixIcon: _yearHasError
                                ? const Icon(Icons.error, color: Colors.red)
                                : const Icon(Icons.check, color: Colors.green),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _yearHasError = !(_formKey
                                  .currentState?.fields['year']
                                  ?.validate() ??
                                  false);
                            });
                          },
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                            FormBuilderValidators.min(0),
                          ]),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        FormBuilderTextField(
                          name: 'brand',
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Marca del Carro',
                            suffixIcon: Icon(Icons.lock, color: Colors.green),
                          ),
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        FormBuilderTextField(
                          name: 'model',
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Modelo del Carro',
                            suffixIcon: Icon(Icons.lock, color: Colors.green),
                          ),
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        FormBuilderTextField(
                          name: 'station',
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Estación',
                            suffixIcon: Icon(Icons.lock, color: Colors.green),
                          ),
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        debugPrint(_formKey.currentState?.value.toString());

                        String message = "";
                        AlertType alertType = AlertType.info;

                        widget.product.name =
                        _formKey.currentState?.value["name"];
                        widget.product.description =
                        _formKey.currentState?.value["description"];
                        widget.product.stock =
                            int.parse(_formKey.currentState?.value["stock"]);
                        widget.product.price =
                            double.parse(_formKey.currentState?.value["price"]);
                        widget.product.weight = double.parse(
                            _formKey.currentState?.value["weight"]);
                        widget.product.year =
                            int.parse(_formKey.currentState?.value["year"]);

                        bool? result = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => FutureProgressDialog(
                            Future(
                                  () async {
                                return await RepairProduct.updateProduct(
                                    repairProduct: widget.product);
                              },
                            ),
                            message: Text(
                              'Actualizando Producto...',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                        );

                        message = result!
                            ? "Producto Actualizado"
                            : "Ocurrió un error";
                        alertType = result ? AlertType.info : AlertType.error;

                        Alert(
                          context: context,
                          type: alertType,
                          title: "Warning",
                          desc: message,
                          buttons: [
                            DialogButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "Cerrar",
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),
                          ],
                        ).show();
                      } else {
                        debugPrint(_formKey.currentState?.value.toString());
                        debugPrint('validation failed');
                      }
                    },
                    icon: Icon(
                      Icons.send,
                      color: Colors.white.withOpacity(0.90),
                    ),
                    label: Text(
                      'Submit',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      _formKey.currentState?.reset();
                    },
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.black,
                    ),
                    label: Text(
                      'Reset',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
