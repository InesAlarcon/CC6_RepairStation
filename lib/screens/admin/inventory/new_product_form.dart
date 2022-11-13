import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:repair_station/models/car_line.dart';
import 'package:repair_station/models/my_repair_station.dart';
import 'package:repair_station/models/product.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class NewProductFormScreen extends StatelessWidget {
  final RepairProductsCatalog catalog;
  const NewProductFormScreen({required this.catalog, super.key});

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
    body: FutureBuilder<AutomobileLines>(
      future: Future(
            () async {
          return await AutomobileLines.getLines();
        },
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${snapshot.error} occurred',
                style: const TextStyle(fontSize: 18),
              ),
            );
          } else if (snapshot.hasData) {
            if (snapshot.data != null) {
              return NewProductForm(
                catalog: catalog,
                automobileLines: snapshot.data!,
              );
            } else {
              return Text(
                "Ocurrió un error",
                style: Theme.of(context).textTheme.headline1,
              );
            }
          }
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    ),
  );
}
}

class NewProductForm extends StatefulWidget {
  final RepairProductsCatalog catalog;
  final AutomobileLines automobileLines;
  const NewProductForm(
  {required this.catalog, required this.automobileLines, super.key});

@override
NewProductFormState createState() => NewProductFormState();
}

class NewProductFormState extends State<NewProductForm> {
  bool autoValidate = true;
  bool _nameHasError = false,
      _idHasError = false,
      _priceHasError = false,
      _stockHasError = false,
      _descriptionHasError = false,
      _weightHasError = false,
      _yearHasError = false;
  final _formKey = GlobalKey<FormBuilderState>();
  late List<String> carBrands;
  late List<String> carModels;
  late String firstModel;

  void updateDropDowns() {
    carBrands = [];
    for (CarLine carLine in widget.automobileLines.lines) {
      carBrands.add(carLine.brand);
    }

    carModels = [];
    carModels.addAll(widget.automobileLines.lines[0].models);
    firstModel = carModels[0];
  }

  @override
  void initState() {
    super.initState();

    updateDropDowns();
  }

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
                skipDisabled: true,
                child: Card(
                  elevation: 8.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
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
                          name: 'articleId',
                          decoration: InputDecoration(
                            labelText: 'Código',
                            suffixIcon: _idHasError
                                ? const Icon(Icons.error, color: Colors.red)
                                : const Icon(Icons.check, color: Colors.green),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _idHasError = !(_formKey
                                  .currentState?.fields['articleId']
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
                            labelText: 'Peso (Kg)',
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
                            suffixIcon: _stockHasError
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
                        FormBuilderDropdown<String>(
                          name: 'brand',
                          initialValue: carBrands[0],
                          onChanged: (value) {
                            for (CarLine carLine
                            in widget.automobileLines.lines) {
                              if (carLine.brand == value) {
                                setState(() {
                                  carModels = [];
                                  carModels.addAll(carLine.models);
                                  firstModel = carModels[0];
                                });

                                _formKey.currentState!.fields['model']?.reset();
                                break;
                              }
                            }

                            print(carModels);
                          },
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                          items: carBrands
                              .map(
                                (carBrand) => DropdownMenuItem(
                              alignment: AlignmentDirectional.center,
                              value: carBrand,
                              child: Text(carBrand),
                            ),
                          )
                              .toList(),
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        FormBuilderRadioGroup(
                          decoration: const InputDecoration(
                              labelText: 'Modelos de Carro'),
                          name: 'model',
                          validator: FormBuilderValidators.required(),
                          options: carModels
                              .map(
                                (carModel) => FormBuilderFieldOption(
                              value: carModel,
                              child: Text(
                                carModel,
                                style:
                                Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                          )
                              .toList(growable: false),
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

                        final newRepairProduct = RepairProduct(
                          articleId: _formKey.currentState?.value["articleId"],
                          name: _formKey.currentState?.value["name"],
                          description: _formKey.currentState?.value["description"],
                          price: double.parse(_formKey.currentState?.value["price"]),
                          weight: double.parse(_formKey.currentState?.value["weight"]),
                          stock: int.parse(_formKey.currentState?.value["stock"]),
                          year: int.parse(_formKey.currentState?.value["year"]),
                          brand: _formKey.currentState?.value["brand"],
                          model: _formKey.currentState?.value["model"],
                          station: MyRepairStation.code,
                        );

                        debugPrint(newRepairProduct.toString());

                        bool inCatalog = false;
                        for (RepairProduct product in widget.catalog.products) {
                          if (product.articleId == newRepairProduct.articleId) {
                            inCatalog = true;
                            break;
                          }
                        }

                        if (!inCatalog) {
                          bool? result = await showDialog<bool>(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => FutureProgressDialog(
                              Future(
                                    () async {
                                  return await RepairProduct.addNewProduct(
                                      repairProduct: newRepairProduct);
                                },
                              ),
                              message: Text(
                                'Añadiendo Producto...',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ),
                          );

                          message =
                          result! ? "Producto añadido" : "Ocurrió un error";
                          alertType = result ? AlertType.info : AlertType.error;

                          if (result) {
                            widget.catalog.products.add(newRepairProduct);
                            _formKey.currentState?.reset();
                          }
                        } else {
                          message = "Un Producto con el mismo código ya existe";
                          alertType = AlertType.error;
                        }

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
