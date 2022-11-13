import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:repair_station/models/my_repair_station.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../models/product.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RepairProductsCatalog>(
      future: Future(
            () async {
          return RepairProductsCatalog.getCatalog();
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
              return InventoryProductList(
                catalog: snapshot.data!,
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
    );
  }
}

class InventoryProductList extends StatefulWidget {
  final RepairProductsCatalog catalog;
  const InventoryProductList({required this.catalog, super.key});

@override
InventoryProductListState createState() => InventoryProductListState();
}

class InventoryProductListState extends State<InventoryProductList> {
  late final List<String> dropDownStationOptions;
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();

    dropDownStationOptions = ["Ninguno"];
    dropDownStationOptions.add(MyRepairStation.code);
    dropDownStationOptions.addAll(MyRepairStation.neighborsCodes);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 8.0,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Text(
                    "Inventario",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 24.0,
          ),
          Card(
            elevation: 8.0,
            child: FormBuilder(
              key: _formKey,
              onChanged: () {
                _formKey.currentState!.save();
                debugPrint(_formKey.currentState!.value.toString());
              },
              autovalidateMode: AutovalidateMode.always,
              initialValue: {
                "station": dropDownStationOptions[0],
              },
              child: ListTile(
                title: FormBuilderDropdown<String>(
                  name: 'station',
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                  items: dropDownStationOptions
                      .map(
                        (stationCode) => DropdownMenuItem(
                      alignment: AlignmentDirectional.center,
                      value: stationCode,
                      child: Text(stationCode),
                    ),
                  )
                      .toList(),
                ),
                trailing: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.white.withOpacity(0.90),
                      ),
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) => FutureProgressDialog(
                            Future(
                                  () async {
                                if (_formKey.currentState?.saveAndValidate() ??
                                    false) {
                                  String? station = _formKey.currentState?.value["station"];
                                  station =
                                  station == "Ninguno" ? null : station;
                                  debugPrint(station);
                                  widget.catalog.products =
                                      (await RepairProductsCatalog.getCatalog(
                                          stationId: station))
                                          .products;
                                  setState(() {});
                                }
                              },
                            ),
                            message: Text(
                              'Actualizando Lista...',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 24.0,
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pushNamed(context, "/newproductform",
                  arguments: widget.catalog)
                  .then(
                    (value) {
                  setState(() {});
                },
              );
            },
            icon: Icon(
              Icons.add,
              color: Colors.white.withOpacity(0.90),
            ),
            label: Text(
              "Añadir Producto",
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          const SizedBox(
            height: 24.0,
          ),
          SizedBox(
            height: 450,
            child: ListView.builder(
              itemCount: widget.catalog.products.length,
              itemBuilder: (context, index) {
                String title =
                    "Artículo: ${widget.catalog.products[index].name} (${widget.catalog.products[index].articleId})";
                String subtitle =
                    "Estación: ${widget.catalog.products[index].station}\n"
                    "Precio: Q${widget.catalog.products[index].price.toStringAsFixed(2)}\n"
                    "Peso: ${widget.catalog.products[index].weight.toStringAsFixed(2)} Kg\n"
                    "Stock: ${widget.catalog.products[index].stock}\n"
                    "Marca: ${widget.catalog.products[index].brand}\n"
                    "Modelo: ${widget.catalog.products[index].model}\n"
                    "Año: ${widget.catalog.products[index].year}\n\n"
                    "Descripción: ${widget.catalog.products[index].description}\n";
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Card(
                    elevation: 4.0,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      title: Text(title),
                      subtitle: Text(subtitle),
                      trailing: IconButton(
                        onPressed: () async {
                          String message = "";
                          AlertType alertType = AlertType.info;

                          bool? result = await showDialog<bool>(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => FutureProgressDialog(
                              Future(
                                    () async {
                                  return await RepairProduct.deleteProduct(
                                    repairProduct:
                                    widget.catalog.products[index],
                                  );
                                },
                              ),
                              message: Text(
                                'Eliminando Producto...',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ),
                          );

                          message = result!
                              ? "Producto Eliminado"
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

                          if (result) {
                            widget.catalog.products.removeAt(index);
                            setState(() {});
                          }
                        },
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                          size: 35,
                        ),
                      ),
                      onTap: () async {
                        Navigator.pushNamed(context, "/productform",
                            arguments: widget.catalog.products[index])
                            .then(
                              (value) {
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
